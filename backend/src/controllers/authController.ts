import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/authService';
import { AuthRequest } from '../middleware/auth';
import { signupSchema, loginSchema } from '../validators/authValidator';
import { User } from '../models/User';
import { AppError } from '../middleware/errorHandler';

const authService = new AuthService();

export async function signup(req: Request, res: Response, next: NextFunction) {
  try {
    const body = signupSchema.parse(req.body);
    const result = await authService.signup(body.email, body.password, body.name);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
}

export async function login(req: Request, res: Response, next: NextFunction) {
  try {
    const body = loginSchema.parse(req.body);
    const result = await authService.login(body.email, body.password);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

export async function me(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) throw new AppError(404, 'User not found');
    res.json(user);
  } catch (err) {
    next(err);
  }
}