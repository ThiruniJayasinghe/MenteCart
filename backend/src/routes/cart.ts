import { Router } from 'express';
import { getCart, addItem, updateItem, removeItem } from '../controllers/cartController';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);
router.get('/', getCart);
router.post('/items', addItem);
router.patch('/items/:itemId', updateItem);
router.delete('/items/:itemId', removeItem);
export default router;