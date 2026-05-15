import { Request, Response, NextFunction } from 'express';
import { logger } from './logger';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public errorCode?: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      statusCode: err.statusCode,
      message: err.message,
      errorCode: err.errorCode,
    });
    return;
  }

  // ADD THIS — log full error details
  console.error('UNHANDLED ERROR:', err);
  console.error('ERROR NAME:', err.name);
  console.error('ERROR MESSAGE:', err.message);
  console.error('ERROR STACK:', err.stack);

  logger.error({ err, path: req.path }, 'Unhandled error');
  res.status(500).json({
    statusCode: 500,
    message: err.message, // ← temporarily show real message
    errorCode: 'INTERNAL_ERROR',
  });
}