import mongoose from 'mongoose';
import { Cart } from '../models/Cart';
import { Service } from '../models/Service';
import { AppError } from '../middleware/errorHandler';
import { env } from '../config/env';

export class CartService {
  async getCart(userId: string) {
    const cart = await Cart.findOne({ userId }).populate('items.serviceId', 'title image category');
    if (!cart) return { items: [], total: 0, itemCount: 0 };

    // Remove expired items
    const now = new Date();
    const activeItems = cart.items.filter((item) => item.expiresAt > now);
    if (activeItems.length !== cart.items.length) {
      cart.items = activeItems as typeof cart.items;
      await cart.save();
    }

    const total = activeItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items: activeItems, total, itemCount: activeItems.length };
  }

  async addItem(userId: string, serviceId: string, date: string, time: string, quantity: number) {
    const service = await Service.findById(serviceId);
    if (!service) throw new AppError(404, 'Service not found');

    const slot = service.slots.find((s) => s.date === date && s.time === time);
    if (!slot) throw new AppError(404, 'Time slot not found');

    const available = slot.capacity - slot.booked;
    if (available < quantity) {
      throw new AppError(409, `Only ${available} spots available for this slot`, 'SLOT_FULL');
    }

    const expiresAt = new Date(Date.now() + env.CART_EXPIRY_MINUTES * 60 * 1000);

    let cart = await Cart.findOne({ userId });
    if (!cart) {
      cart = await Cart.create({ userId, items: [] });
    }

    // Prevent duplicate same service + same slot
    const existing = cart.items.find(
      (i) => i.serviceId.toString() === serviceId && i.date === date && i.time === time
    );
    if (existing) {
      existing.quantity = quantity;
      existing.expiresAt = expiresAt;
    } else {
      cart.items.push({
        serviceId: new mongoose.Types.ObjectId(serviceId),
        title: service.title,
        price: service.price,
        date,
        time,
        quantity,
        expiresAt,
      } as any);
    }

    await cart.save();
    return cart;
  }

  async updateItem(
    userId: string,
    itemId: string,
    updates: { date?: string; time?: string; quantity?: number }
  ) {
    const cart = await Cart.findOne({ userId });
    if (!cart) throw new AppError(404, 'Cart not found');

    // Use .find() instead of .id() to avoid the missing method TypeScript error
    const item = cart.items.find((i) => i._id.toString() === itemId);
    if (!item) throw new AppError(404, 'Cart item not found');

    if (updates.date) item.date = updates.date;
    if (updates.time) item.time = updates.time;
    if (updates.quantity) item.quantity = updates.quantity;
    item.expiresAt = new Date(Date.now() + env.CART_EXPIRY_MINUTES * 60 * 1000);

    await cart.save();
    return cart;
  }

  async removeItem(userId: string, itemId: string) {
    const cart = await Cart.findOne({ userId });
    if (!cart) throw new AppError(404, 'Cart not found');

    cart.items = cart.items.filter((i) => i._id.toString() !== itemId) as typeof cart.items;
    await cart.save();
    return cart;
  }
}