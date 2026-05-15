import { z } from 'zod';

export const checkoutSchema = z.object({
  paymentMethod: z.enum(['online', 'cash', 'pay_on_arrival']),
});