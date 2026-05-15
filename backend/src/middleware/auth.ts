import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export interface AuthRequest extends Request {
  userId?: string;
  userEmail?: string;
}

export function authenticate(req: AuthRequest, res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    res.status(401).json({ statusCode: 401, message: 'Missing authorization header' });
    return;
  }

  const token = header.split(' ')[1];
  try {
    const payload = jwt.verify(token, env.JWT_SECRET) as { userId: string; email: string };
    req.userId = payload.userId;
    req.userEmail = payload.email;
    next();
  } catch {
    res.status(401).json({ statusCode: 401, message: 'Invalid or expired token', errorCode: 'TOKEN_INVALID' });
  }
}