import express from 'express';
import { addGoal, getGoals,deleteGoal } from '../../controllers/goal_controllers/goalController.js';

const router = express.Router();

// Add a new goal
router.post('/addGoal', addGoal);

// Get all goals for a user
router.get('/getGoals/:userId', getGoals);

//Delete a goal
router.delete('/deleteGoal/:goalId', deleteGoal);

export default router;