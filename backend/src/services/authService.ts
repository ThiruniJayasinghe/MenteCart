import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';
import { AppError } from '../middleware/errorHandler';
import { env } from '../config/env';

export class AuthService {
  async signup(email: string, password: string, name: string) {
    const existing = await User.findOne({ email });
    if (existing) {
      throw new AppError(409, 'Email already registered', 'EMAIL_TAKEN');
    }

    const hashed = await bcrypt.hash(password, 12);
    const user = await User.create({ email, password: hashed, name });

    const token = this.signToken(user._id.toString(), user.email);
    return { token, user: { id: user._id, email: user.email, name: user.name } };
  }

  async login(email: string, password: string) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new AppError(401, 'Invalid credentials', 'INVALID_CREDENTIALS');
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      throw new AppError(401, 'Invalid credentials', 'INVALID_CREDENTIALS');
    }

    const token = this.signToken(user._id.toString(), user.email);
    return { token, user: { id: user._id, email: user.email, name: user.name } };
  }

  private signToken(userId: string, email: string): string {
    return jwt.sign({ userId, email }, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'],
    });
  }
}