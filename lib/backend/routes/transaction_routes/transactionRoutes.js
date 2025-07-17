import express from 'express';
import { getTransactions, addTransaction, deleteTransaction } from '../../controllers/transaction_controllers/transactionController.js';

const router = express.Router();

// Route to add a new transaction
router.post('/add', addTransaction);

// Route to get transactions for a specific user
router.get('/:userId', getTransactions);

// Route to delete a transaction by ID
router.delete('/delete/:transactionId', deleteTransaction);

export default router;