import { Request, Response, NextFunction } from 'express';
import { Service } from '../models/Service';
import { AppError } from '../middleware/errorHandler';

export async function listServices(req: Request, res: Response, next: NextFunction) {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 50);
    const skip = (page - 1) * limit;

    const filter: Record<string, unknown> = { isActive: true };
    if (req.query.category) filter.category = req.query.category;
    if (req.query.search) filter.$text = { $search: req.query.search as string };

    const [services, total] = await Promise.all([
      Service.find(filter).select('-slots').skip(skip).limit(limit),
      Service.countDocuments(filter),
    ]);

    res.json({ services, total, page, limit, hasMore: skip + services.length < total });
  } catch (err) {
    next(err);
  }
}

export async function getService(req: Request, res: Response, next: NextFunction) {
  try {
    const service = await Service.findById(req.params.id);
    if (!service) throw new AppError(404, 'Service not found');

    // Only show available slots (booked < capacity)
    const availableSlots = service.slots.filter((s) => s.booked < s.capacity);
    res.json({ ...service.toJSON(), slots: availableSlots });
  } catch (err) {
    next(err);
  }
}