import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { CartService } from '../services/cartService';
import { addItemSchema, updateItemSchema } from '../validators/cartValidator';

const cartService = new CartService();

export async function getCart(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const cart = await cartService.getCart(req.userId!);
    res.json(cart);
  } catch (err) {
    next(err);
  }
}

export async function addItem(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const body = addItemSchema.parse(req.body);
    const cart = await cartService.addItem(
      req.userId!,
      body.serviceId,
      body.date,
      body.time,
      body.quantity
    );
    res.status(201).json(cart);
  } catch (err) {
    next(err);
  }
}

export async function updateItem(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const body = updateItemSchema.parse(req.body);
    
    const cart = await cartService.updateItem(req.userId!, String(req.params.itemId), body);
    res.json(cart);
  } catch (err) {
    next(err);
  }
}

export async function removeItem(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const cart = await cartService.removeItem(req.userId!, String(req.params.itemId));
    res.json(cart);
  } catch (err) {
    next(err);
  }
}