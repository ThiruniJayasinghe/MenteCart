import mongoose, { Document, Schema } from 'mongoose';

export interface ITimeSlot {
  date: string;
  time: string;
  capacity: number;
  booked: number;
}

export interface IService extends Document {
  _id: mongoose.Types.ObjectId;
  title: string;
  description: string;
  price: number;
  duration: number;
  category: string;
  image: string;
  slots: ITimeSlot[];
  isActive: boolean;
}

const timeSlotSchema = new Schema<ITimeSlot>({
  date: { type: String, required: true },
  time: { type: String, required: true },
  capacity: { type: Number, required: true, min: 1 },
  booked: { type: Number, default: 0, min: 0 },
});

const serviceSchema = new Schema<IService>(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String, required: true },
    price: { type: Number, required: true, min: 0 },
    duration: { type: Number, required: true },
    category: { type: String, required: true, index: true },
    image: { type: String, required: true },
    slots: [timeSlotSchema],
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

serviceSchema.index({ title: 'text' });

export const Service = mongoose.model<IService>('Service', serviceSchema);