import express from "express";
import { uploadPdf, getUserPdfs, deletePdf, getPdfById } from "../../controllers/pdf_controllers/pdfController.js";

const router = express.Router();

// Test endpoint to verify route is working
router.get("/test", (req, res) => {
    res.status(200).json({
        success: true,
        message: "PDF route is working!",
        timestamp: new Date().toISOString()
    });
});

// Test endpoint for form data
router.post("/test-form", (req, res) => {
    console.log("Form test endpoint hit!");
    console.log("Headers:", req.headers);
    console.log("Body:", req.body);
    console.log("Files:", req.files);

    res.status(200).json({
        success: true,
        message: "Form data received!",
        receivedFields: req.body,
        hasFiles: !!req.files,
        timestamp: new Date().toISOString()
    });
});

// Upload PDF file
router.post("/upload", uploadPdf);

// Get all PDFs for a user
router.get("/user/:userId", getUserPdfs);

// Get specific PDF by ID
router.get("/:id", getPdfById);

// Delete PDF by ID
router.delete("/:id", deletePdf);

export default router;