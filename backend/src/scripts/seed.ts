import mongoose from 'mongoose';
import { Service } from '../models/Service';
import { env } from '../config/env';

const services = [
  {
    title: 'Home Deep Cleaning',
    description: 'Professional deep cleaning of your entire home. Our team uses eco-friendly products.',
    price: 4500,
    duration: 180,
    category: 'cleaning',
    image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    slots: generateSlots(5),
  },
  {
    title: 'Plumbing Repair',
    description: 'Fix leaks, install fixtures, and handle all plumbing issues with certified plumbers.',
    price: 2500,
    duration: 60,
    category: 'plumbing',
    image: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
    slots: generateSlots(3),
  },
  {
    title: 'Math Tutoring',
    description: 'One-on-one math tutoring for all levels from grade 6 to A/L.',
    price: 1500,
    duration: 90,
    category: 'tutoring',
    image: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=400',
    slots: generateSlots(8),
  },
  {
    title: 'Beauty Appointment',
    description: 'Hair styling, makeup, and beauty treatments by professional beauticians.',
    price: 3000,
    duration: 120,
    category: 'beauty',
    image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
    slots: generateSlots(4),
  },
  {
    title: 'AC Service & Repair',
    description: 'Air conditioner cleaning, gas refilling, and repairs.',
    price: 3500,
    duration: 90,
    category: 'appliance',
    image: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400',
    slots: generateSlots(3),
  },
  {
    title: 'English Tutoring',
    description: 'Improve spoken and written English with experienced tutors.',
    price: 1800,
    duration: 60,
    category: 'tutoring',
    image: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
    slots: generateSlots(6),
  },
];

function generateSlots(capacity: number) {
  const slots = [];
  const today = new Date();
  for (let d = 1; d <= 7; d++) {
    const date = new Date(today);
    date.setDate(today.getDate() + d);
    const dateStr = date.toISOString().split('T')[0];
    for (const time of ['09:00', '11:00', '14:00', '16:00']) {
      slots.push({ date: dateStr, time, capacity, booked: 0 });
    }
  }
  return slots;
}

async function seed() {
  await mongoose.connect(env.MONGO_URI);
  await Service.deleteMany({});
  await Service.insertMany(services);
  console.log('Seeded', services.length, 'services');
  process.exit(0);
}

seed().catch(console.error);