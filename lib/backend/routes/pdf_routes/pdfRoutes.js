import express from "express";
import { uploadPdf, getUserPdfs, deletePdf, getPdfById } from "../../controllers/pdf_controllers/pdfController.js";

const router = express.Router();

// Upload PDF file
router.post("/upload", uploadPdf);

// Get all PDFs for a user
router.get("/user/:userId", getUserPdfs);

// Get specific PDF by ID
router.get("/:id", getPdfById);

// Delete PDF by ID
router.delete("/:id", deletePdf);

export default router;