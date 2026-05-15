import dotenv from 'dotenv';
dotenv.config();

export const env = {
  PORT: parseInt(process.env.PORT || '3000', 10),
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/mentecart',
  REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379',
  JWT_SECRET: process.env.JWT_SECRET || '',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h',
  PAYHERE_MERCHANT_ID: process.env.PAYHERE_MERCHANT_ID || '',
  PAYHERE_MERCHANT_SECRET: process.env.PAYHERE_MERCHANT_SECRET || '',
  PAYHERE_BASE_URL: process.env.PAYHERE_BASE_URL || 'https://sandbox.payhere.lk/pay/checkout',
  PUBLIC_URL: process.env.PUBLIC_URL || 'https://stooge-causing-prodigal.ngrok-free.dev',
  CART_EXPIRY_MINUTES: parseInt(process.env.CART_EXPIRY_MINUTES || '15', 10),
  MAX_BOOKINGS_PER_DAY: parseInt(process.env.MAX_BOOKINGS_PER_DAY || '3', 10),
  NODE_ENV: process.env.NODE_ENV || 'development',
};

if (!env.JWT_SECRET) {
  throw new Error('JWT_SECRET must be set in environment variables');
}