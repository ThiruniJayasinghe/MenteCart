import { createClient } from 'redis';
import { env } from './env';
import { logger } from '../middleware/logger';

export const redisClient = createClient({ url: env.REDIS_URL });

redisClient.on('error', (err) => logger.error({ err }, 'Redis error'));
redisClient.on('connect', () => logger.info('Redis connected'));

export async function connectRedis(): Promise<void> {
  await redisClient.connect();
}