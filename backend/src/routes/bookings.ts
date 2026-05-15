import { Router } from 'express';
import { checkout, listBookings, getBooking, cancelBooking } from '../controllers/bookingController';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);
router.post('/checkout', checkout);
router.get('/', listBookings);
router.get('/:id', getBooking);
router.post('/:id/cancel', cancelBooking);
export default router;