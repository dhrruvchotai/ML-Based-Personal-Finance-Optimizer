import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import userRoutes from "./routes/user_routes/userRoutes.js";
import transactionRoutes from "./routes/transaction_routes/transactionRoutes.js";
import express from "express";

// Load environment variables from .env file
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;
const MONGODB_CONNECTION_STRING = process.env.MONGODB_CONNECTION_STRING;

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.use("/api/users", userRoutes);
app.use("/api/transactions", transactionRoutes);

// MongoDB Connection
mongoose.connect(MONGODB_CONNECTION_STRING)
    .then(() => {
        console.log("MongoDB connected!");
        // Start server only after DB connection
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch((err) => {
        console.error("MongoDB connection error:", err);
    });