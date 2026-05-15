import mongoose from 'mongoose';
import { Cart } from '../models/Cart';
import { Service } from '../models/Service';
import { Booking, BookingStatus, VALID_TRANSITIONS } from '../models/Booking';
import { AppError } from '../middleware/errorHandler';
import { env } from '../config/env';
import { logger } from '../middleware/logger';

export class BookingService {
  async checkout(userId: string, paymentMethod: 'online' | 'cash' | 'pay_on_arrival') {
    const cart = await Cart.findOne({ userId });
    if (!cart || cart.items.length === 0) {
      throw new AppError(400, 'Cart is empty', 'CART_EMPTY');
    }

    // Check daily booking limit
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayCount = await Booking.countDocuments({
      userId,
      createdAt: { $gte: today },
      status: { $nin: ['cancelled', 'failed'] },
    });
    if (todayCount >= env.MAX_BOOKINGS_PER_DAY) {
      throw new AppError(
        429,
        `Maximum ${env.MAX_BOOKINGS_PER_DAY} bookings allowed per day`,
        'DAILY_LIMIT_EXCEEDED'
      );
    }

    // Remove expired items
    const now = new Date();
    const activeItems = cart.items.filter((item) => item.expiresAt > now);
    if (activeItems.length === 0) {
      throw new AppError(
        400,
        'All cart items have expired. Please re-add services.',
        'CART_EXPIRED'
      );
    }

    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // Check slot availability and decrement capacity for each item
      for (const item of activeItems) {
        // Fetch the service and check slot availability
        const service = await Service.findById(item.serviceId).session(session);
        if (!service) {
          throw new AppError(404, `Service "${item.title}" not found`, 'SERVICE_NOT_FOUND');
        }

        const slot = service.slots.find(
          (s) => s.date === item.date && s.time === item.time
        );
        if (!slot) {
          throw new AppError(
            409,
            `Slot for ${item.title} on ${item.date} at ${item.time} not found`,
            'SLOT_NOT_FOUND'
          );
        }

        const available = slot.capacity - slot.booked;
        if (available < item.quantity) {
          throw new AppError(
            409,
            `Slot for ${item.title} on ${item.date} at ${item.time} is no longer available`,
            'SLOT_UNAVAILABLE'
          );
        }

        // Atomically decrement booked count
        await Service.findOneAndUpdate(
          {
            _id: item.serviceId,
            'slots.date': item.date,
            'slots.time': item.time,
          },
          { $inc: { 'slots.$.booked': item.quantity } },
          { session, new: true }
        );
      }

      const totalAmount = activeItems.reduce(
        (sum, i) => sum + i.price * i.quantity,
        0
      );
      const isUnpaid =
        paymentMethod === 'cash' || paymentMethod === 'pay_on_arrival';

      const booking = await Booking.create(
        [
          {
            userId,
            items: activeItems.map((i) => ({
              serviceId: i.serviceId,
              title: i.title,
              price: i.price,
              date: i.date,
              time: i.time,
              quantity: i.quantity,
            })),
            totalAmount,
            status: isUnpaid ? 'confirmed' : 'pending',
            paymentMethod,
            paymentStatus: isUnpaid ? 'unpaid' : 'unpaid',
            statusAudit: isUnpaid
              ? [
                  {
                    from: 'pending',
                    to: 'confirmed',
                    at: new Date(),
                    reason: 'Cash/pay-on-arrival booking',
                  },
                ]
              : [],
            confirmedAt: isUnpaid ? new Date() : undefined,
          },
        ],
        { session }
      );

      // Clear the cart
      await Cart.findOneAndUpdate(
        { userId },
        { $set: { items: [] } },
        { session }
      );

      await session.commitTransaction();
      logger.info({ bookingId: booking[0]._id, userId }, 'Booking created');
      return booking[0];
    } catch (err) {
      await session.abortTransaction();
      throw err;
    } finally {
      session.endSession();
    }
  }

  async transitionStatus(
    bookingId: string,
    userId: string,
    toStatus: BookingStatus,
    reason?: string
  ) {
    const booking = await Booking.findOne({ _id: bookingId, userId });
    if (!booking) throw new AppError(404, 'Booking not found');

    const allowed = VALID_TRANSITIONS[booking.status];
    if (!allowed.includes(toStatus)) {
      throw new AppError(
        400,
        `Cannot transition from ${booking.status} to ${toStatus}`,
        'INVALID_TRANSITION'
      );
    }

    booking.statusAudit.push({
      from: booking.status,
      to: toStatus,
      at: new Date(),
      reason,
    });
    booking.status = toStatus;

    if (toStatus === 'cancelled') {
      booking.cancelledAt = new Date();
      // Release capacity back
      for (const item of booking.items) {
        await Service.findOneAndUpdate(
          {
            _id: item.serviceId,
            'slots.date': item.date,
            'slots.time': item.time,
          },
          { $inc: { 'slots.$.booked': -item.quantity } }
        );
      }
    }

    if (toStatus === 'confirmed') booking.confirmedAt = new Date();

    await booking.save();
    return booking;
  }

  async getUserBookings(userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;
    const [bookings, total] = await Promise.all([
      Booking.find({ userId }).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Booking.countDocuments({ userId }),
    ]);
    return { bookings, total, hasMore: skip + bookings.length < total };
  }
}