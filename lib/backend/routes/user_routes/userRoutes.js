import express from "express";
import { addUser, getAllUsers, deleteUser } from "../../controllers/user_controllers/userController.js";

const router = express.Router();

// Add a new user
router.post("/addUser", addUser);

// Get all users
router.get("/getAllUsers", getAllUsers);

// Delete a user by ID
router.delete("/deleteUser/:id", deleteUser);

export default router;