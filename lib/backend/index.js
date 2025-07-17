import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";
import transactionRoutes from "./routes/transaction_routes/transactionRoutes.js";

const app = express();
app.use(cors());
dotenv.config();
app.use(express.json());
app.use("/api/transactions",transactionRoutes);

mongoose.connect("mongodb+srv://vvandan1378:vvandan1378@cluster0.duk8w.mongodb.net/")
    .then(()=> console.log("Connected to mongoDB"))
    .catch(err=>console.log("Failed to connect to mongoDB ",err))

const port = process.env.PORT || 5000;


 
app.listen(port, ()=>{
    console.log(`server running on port ${port}`)
})