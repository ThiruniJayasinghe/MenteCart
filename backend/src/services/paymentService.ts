import crypto from 'crypto';
import { Booking } from '../models/Booking';
import { PaymentLog } from '../models/PaymentLog';
import { Service } from '../models/Service';
import { AppError } from '../middleware/errorHandler';
import { env } from '../config/env';
import { logger } from '../middleware/logger';

export class PaymentService {
  generateCheckoutData(
    booking: any,
    customer: { name: string; email: string },
    returnUrl: string,
    cancelUrl: string,
    notifyUrl: string,
    phone: string = '0771234567',
    address: string = 'N/A',
    city: string = 'Colombo',
  ) {
    const amount = parseFloat(booking.totalAmount).toFixed(2);
    const currency = 'LKR';
    const orderId = booking._id.toString();

    const nameParts = customer.name.trim().split(' ');
    const firstName = nameParts[0] ?? 'Customer';
    const lastName = nameParts.slice(1).join(' ') || 'N/A';

    const secretMd5 = crypto
      .createHash('md5')
      .update(env.PAYHERE_MERCHANT_SECRET)
      .digest('hex')
      .toUpperCase();

    const hash = crypto
      .createHash('md5')
      .update(`${env.PAYHERE_MERCHANT_ID}${orderId}${amount}${currency}${secretMd5}`)
      .digest('hex')
      .toUpperCase();

    return {
      merchant_id: env.PAYHERE_MERCHANT_ID,
      merchant_secret: env.PAYHERE_MERCHANT_SECRET,
      return_url: returnUrl,
      cancel_url: cancelUrl,
      notify_url: notifyUrl,
      order_id: orderId,
      items: booking.items.map((i: any) => i.title).join(', '),
      currency,
      amount,
      hash,
      first_name: firstName,
      last_name: lastName,
      email: customer.email,
      phone,
      address,
      city,
      country: 'Sri Lanka',
    };
  }

  verifyWebhookSignature(payload: Record<string, string>): boolean {
    const { merchant_id, order_id, payhere_amount, payhere_currency, status_code, md5sig } =
      payload;

    const secretMd5 = crypto
      .createHash('md5')
      .update(env.PAYHERE_MERCHANT_SECRET)
      .digest('hex')
      .toUpperCase();

    const expected = crypto
      .createHash('md5')
      .update(
        `${merchant_id}${order_id}${payhere_amount}${payhere_currency}${status_code}${secretMd5}`
      )
      .digest('hex')
      .toUpperCase();

    return md5sig === expected;
  }

  async processWebhook(payload: Record<string, string>) {
    const { order_id, status_code, payment_id, payhere_amount, payhere_currency } = payload;

    const existing = await PaymentLog.findOne({ orderId: order_id });
    if (existing) {
      logger.info({ orderId: order_id }, 'Duplicate webhook ignored');
      return;
    }

    const booking = await Booking.findById(order_id);
    if (!booking) throw new AppError(404, 'Booking not found for webhook');

    await PaymentLog.create({
      bookingId: booking._id,
      orderId: order_id,
      paymentId: payment_id,
      status: status_code,
      amount: parseFloat(payhere_amount),
      currency: payhere_currency,
      rawPayload: payload,
    });

    if (status_code === '2') {
      booking.paymentStatus = 'paid';
      booking.status = 'confirmed';
      booking.confirmedAt = new Date();
      booking.paymentOrderId = payment_id;
      booking.statusAudit.push({
        from: 'pending',
        to: 'confirmed',
        at: new Date(),
        reason: 'PayHere payment success',
      });
      await booking.save();
      logger.info({ bookingId: booking._id }, 'Payment confirmed');
    } else if (status_code === '-2' || status_code === '-1') {
      booking.paymentStatus = 'failed';
      booking.status = 'failed';
      booking.statusAudit.push({
        from: 'pending',
        to: 'failed',
        at: new Date(),
        reason: `PayHere status: ${status_code}`,
      });
      await booking.save();

      for (const item of booking.items) {
        await Service.findOneAndUpdate(
          { _id: item.serviceId, 'slots.date': item.date, 'slots.time': item.time },
          { $inc: { 'slots.$.booked': -item.quantity } }
        );
      }
      logger.warn({ bookingId: booking._id, status_code }, 'Payment failed, capacity released');
    }
  }
}