import mongoose, { Document, Schema } from 'mongoose';

export interface IPaymentLog extends Document {
  bookingId: mongoose.Types.ObjectId;
  orderId: string;
  paymentId: string;
  status: string;
  amount: number;
  currency: string;
  rawPayload: Record<string, unknown>;
  processedAt: Date;
}

const paymentLogSchema = new Schema<IPaymentLog>({
  bookingId: { type: Schema.Types.ObjectId, ref: 'Booking', required: true },
  orderId: { type: String, required: true, unique: true },
  paymentId: String,
  status: String,
  amount: Number,
  currency: String,
  rawPayload: Schema.Types.Mixed,
  processedAt: { type: Date, default: Date.now },
});

export const PaymentLog = mongoose.model<IPaymentLog>('PaymentLog', paymentLogSchema);