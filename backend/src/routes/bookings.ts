import { Router } from 'express';
import { checkout, listBookings, getBooking, cancelBooking } from '../controllers/bookingController';
import { authenticate } from '../middleware/auth';
import { Booking } from '../models/Booking';
import { AppError } from '../middleware/errorHandler';

const router = Router();
router.use(authenticate);
router.post('/checkout', checkout);
router.get('/', listBookings);
router.get('/:id', getBooking);
router.post('/:id/cancel', cancelBooking);

router.post('/:id/confirm-payment', async (req, res, next) => {
  try {
    const booking = await Booking.findOne({ _id: req.params.id, userId: (req as any).userId });
    if (!booking) throw new AppError(404, 'Booking not found');

    // Only confirm if still pending (avoid double confirm)
    if (booking.status === 'pending') {
      booking.status = 'confirmed';
      booking.paymentStatus = 'paid';
      booking.confirmedAt = new Date();
      booking.paymentOrderId = req.body.paymentId;
      booking.statusAudit.push({
        from: 'pending',
        to: 'confirmed',
        at: new Date(),
        reason: 'PayHere payment confirmed by client',
      });
      await booking.save();
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

export default router;