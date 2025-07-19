import Users from "../../models/userModel.js";
import mongoose from "mongoose";
import axios from "axios";

// Add a new user
export const addUser = async (req, res) => {
  try {
    const { userName, email } = req.body;

    console.log(req.body);

    if (userName === "" || email === "") {
      return res.status(400).json({ message: "All fields are required" });
    }

    const userExists = await Users.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: "User already exists" });
    }
    const user = new Users({ userName, email, password: req.body.password || "" });
    const userData = await user.save();

   

    //call n8n web hook
    try {
      await axios.post(
        "https://dhruv-chotai-10.app.n8n.cloud/webhook-test/user-added",
        {
          userName,
          email,
          _id: user._id,
        }
      );
      console.log("Webhook triggered successfully");
    } catch (webhookErr) {
      console.error("Failed to call n8n webhook:", webhookErr.message);
    }

    res.status(201).json({ message: "User created successfully", userData });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get all users
export const getAllUsers = async (req, res) => {
  try {
    const users = await Users.find({}, "-password"); // Exclude password
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Delete a specific user by ID
export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await Users.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    // Cascade delete: Remove all transactions for this user
    const Transactions = (await import("../../models/transactionModel.js"))
      .default;
    const result = await Transactions.deleteMany({
      userId: new mongoose.Types.ObjectId(id),
    });
    console.log(`Deleted ${result.deletedCount} transactions for user ${id}`);
    res
      .status(200)
      .json({
        message: `User and their ${result.deletedCount} transactions deleted successfully`,
      });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};