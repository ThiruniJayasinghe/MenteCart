import { Request, Response, NextFunction } from 'express';
import { PaymentService } from '../services/paymentService';
import { logger } from '../middleware/logger';

const paymentService = new PaymentService();

export async function payhereWebhook(req: Request, res: Response, next: NextFunction) {
  try {
    logger.info({ body: req.body }, 'PayHere webhook received');

    // Verify signature first — ignore tampered requests
    const isValid = paymentService.verifyWebhookSignature(req.body);
    if (!isValid) {
      logger.warn({ body: req.body }, 'Invalid PayHere webhook signature');
      return res.status(400).send('Invalid signature');
    }

    await paymentService.processWebhook(req.body);

    // PayHere expects HTTP 200, otherwise it retries
    res.sendStatus(200);
  } catch (err) {
    next(err);
  }
}