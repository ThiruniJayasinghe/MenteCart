import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { env } from './config/env';
import { connectDatabase } from './config/database';
import { connectRedis } from './config/redis';
import { httpLogger, logger } from './middleware/logger';
import { errorHandler } from './middleware/errorHandler';
import authRoutes from './routes/auth';
import serviceRoutes from './routes/services';
import cartRoutes from './routes/cart';
import bookingRoutes from './routes/bookings';
import webhookRoutes from './routes/webhook';

async function bootstrap() {
  await connectDatabase();
  await connectRedis();

  const app = express();

  app.use(helmet());
  app.use(cors({ origin: '*' }));
  app.use(httpLogger);

  // Body parsers 
  // Webhook route needs urlencoded BEFORE express.json()
  app.use('/webhooks', express.urlencoded({ extended: true })); // PayHere sends url-encoded body
  app.use(express.json());

  // Payment redirect stubs 
  // PayHere redirects to these after payment — Flutter WebView intercepts them
  app.get('/payment/return', (_req, res) => res.send('OK'));
  app.get('/payment/cancel', (_req, res) => res.send('OK'));

  // Routes 
  app.use('/auth', authRoutes);
  app.use('/services', serviceRoutes);
  app.use('/cart', cartRoutes);
  app.use('/bookings', bookingRoutes);
  app.use('/webhooks', webhookRoutes);

  app.get('/health', (_req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

  app.use(errorHandler);

  app.listen(env.PORT, () => {
    logger.info({ port: env.PORT }, `Server running`);
  });
}

bootstrap().catch((err) => {
  console.error('Failed to start server', err);
  process.exit(1);
});