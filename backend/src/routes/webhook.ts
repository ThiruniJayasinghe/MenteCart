import { Router } from 'express';
import { payhereWebhook } from '../controllers/webhookController';

const router = Router();

// PayHere POSTs url-encoded data here after payment
router.post('/payhere', payhereWebhook);

export default router;