import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { BookingService } from '../services/bookingService';
import { PaymentService } from '../services/paymentService';
import { checkoutSchema } from '../validators/bookingValidator';
import { AppError } from '../middleware/errorHandler';
import { User } from '../models/User';
import { env } from '../config/env';

const bookingService = new BookingService();
const paymentService = new PaymentService();

export async function checkout(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const { paymentMethod, phone, address, city } = req.body;
    const booking = await bookingService.checkout(req.userId!, paymentMethod);

    if (paymentMethod === 'online') {
      const user = await User.findById(req.userId).select('name email');
      if (!user) throw new AppError(404, 'User not found');

      const baseUrl = env.PUBLIC_URL;

      const checkoutData = paymentService.generateCheckoutData(
        booking,
        { name: user.name, email: user.email },
        `${baseUrl}/payment/return`,
        `${baseUrl}/payment/cancel`,
        `${baseUrl}/webhooks/payhere`,
        phone || '0771234567',
        address || 'N/A',
        city || 'Colombo',
      );
      res.status(201).json({ booking, checkoutData });
    } else {
      res.status(201).json({ booking });
    }
  } catch (err) {
    next(err);
  }
}

export async function listBookings(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const page = parseInt(String(req.query.page), 10) || 1;
    const limit = parseInt(String(req.query.limit), 10) || 20;
    const result = await bookingService.getUserBookings(req.userId!, page, limit);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

export async function getBooking(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const { Booking } = await import('../models/Booking');
    const booking = await Booking.findOne({ _id: String(req.params.id), userId: req.userId });
    if (!booking) throw new AppError(404, 'Booking not found');
    res.json(booking);
  } catch (err) {
    next(err);
  }
}

export async function cancelBooking(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const booking = await bookingService.transitionStatus(
      String(req.params.id),
      req.userId!,
      'cancelled',
      'User requested cancellation'
    );
    res.json(booking);
  } catch (err) {
    next(err);
  }
}