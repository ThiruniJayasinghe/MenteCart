import mongoose, { Document, Schema } from 'mongoose';

export interface ICartItem {
  _id: mongoose.Types.ObjectId;
  serviceId: mongoose.Types.ObjectId;
  title: string;
  price: number;
  date: string;
  time: string;
  quantity: number;
  expiresAt: Date;
}

export interface ICart extends Document {
  _id: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  items: ICartItem[];
  updatedAt: Date;
}

const cartItemSchema = new Schema<ICartItem>({
  serviceId: { type: Schema.Types.ObjectId, ref: 'Service', required: true },
  title: { type: String, required: true },
  price: { type: Number, required: true },
  date: { type: String, required: true },
  time: { type: String, required: true },
  quantity: { type: Number, default: 1, min: 1 },
  expiresAt: { type: Date, required: true },
});

const cartSchema = new Schema<ICart>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    items: [cartItemSchema],
  },
  { timestamps: true }
);

export const Cart = mongoose.model<ICart>('Cart', cartSchema);