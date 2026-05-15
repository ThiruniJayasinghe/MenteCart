import mongoose, { Document, Schema } from 'mongoose';

export type BookingStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'failed';
export type PaymentMethod = 'online' | 'cash' | 'pay_on_arrival';
export type PaymentStatus = 'unpaid' | 'paid' | 'failed' | 'refunded';

export interface IStatusAudit {
  from: BookingStatus;
  to: BookingStatus;
  at: Date;
  reason?: string;
}

export interface IBookingItem {
  serviceId: mongoose.Types.ObjectId;
  title: string;
  price: number;
  date: string;
  time: string;
  quantity: number;
}

export interface IBooking extends Document {
  _id: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  items: IBookingItem[];
  totalAmount: number;
  status: BookingStatus;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  paymentOrderId?: string;
  statusAudit: IStatusAudit[];
  cancelledAt?: Date;
  confirmedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const bookingItemSchema = new Schema<IBookingItem>({
  serviceId: { type: Schema.Types.ObjectId, ref: 'Service', required: true },
  title: { type: String, required: true },
  price: { type: Number, required: true },
  date: { type: String, required: true },
  time: { type: String, required: true },
  quantity: { type: Number, required: true },
});

const statusAuditSchema = new Schema<IStatusAudit>({
  from: { type: String, required: true },
  to: { type: String, required: true },
  at: { type: Date, default: Date.now },
  reason: String,
});

const VALID_TRANSITIONS: Record<BookingStatus, BookingStatus[]> = {
  pending: ['confirmed', 'failed', 'cancelled'],
  confirmed: ['completed', 'cancelled'],
  completed: [],
  cancelled: [],
  failed: [],
};

const bookingSchema = new Schema<IBooking>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    items: [bookingItemSchema],
    totalAmount: { type: Number, required: true },
    status: { type: String, enum: Object.keys(VALID_TRANSITIONS), default: 'pending' },
    paymentMethod: { type: String, enum: ['online', 'cash', 'pay_on_arrival'], required: true },
    paymentStatus: { type: String, enum: ['unpaid', 'paid', 'failed', 'refunded'], default: 'unpaid' },
    paymentOrderId: String,
    statusAudit: [statusAuditSchema],
    cancelledAt: Date,
    confirmedAt: Date,
  },
  { timestamps: true }
);

export { VALID_TRANSITIONS };
export const Booking = mongoose.model<IBooking>('Booking', bookingSchema);