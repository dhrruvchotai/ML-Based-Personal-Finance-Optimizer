import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import { dirname } from "path";
import PdfModel from "../../models/pdfModel.js";
import mongoose from "mongoose";
import axios from "axios";

// Get current directory
const __filename = fileURLToPath(
    import.meta.url);
const __dirname = dirname(__filename);

// Configure multer for file upload
const storage = multer.diskStorage({
    destination: function(req, file, cb) {
        // Use process.cwd() for more reliable path resolution
        const uploadDir = path.join(process.cwd(), "uploads", "pdfs");
        console.log("Upload directory:", uploadDir);

        try {
            if (!fs.existsSync(uploadDir)) {
                fs.mkdirSync(uploadDir, { recursive: true });
                console.log("Created upload directory:", uploadDir);
            }
            cb(null, uploadDir);
        } catch (error) {
            console.error("Error creating upload directory:", error);
            cb(error);
        }
    },
    filename: function(req, file, cb) {
        // Generate unique filename with timestamp
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, `financial_report_${uniqueSuffix}${ext}`);
    },
});

// File filter to only allow PDF files
const fileFilter = (req, file, cb) => {
    console.log("File upload attempt:", {
        originalname: file.originalname,
        mimetype: file.mimetype,
        fieldname: file.fieldname
    });

    // Check both mimetype and file extension
    const isPdfMimeType = file.mimetype === "application/pdf";
    const isPdfExtension = file.originalname.toLowerCase().endsWith('.pdf');

    if (isPdfMimeType || isPdfExtension) {
        cb(null, true);
    } else {
        cb(new Error(`Only PDF files are allowed! Received: ${file.mimetype} with name: ${file.originalname}`), false);
    }
};

// Configure multer upload
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
});

// Upload PDF controller
export const uploadPdf = async(req, res) => {
    console.log("PDF upload request received");
    console.log("Request headers:", req.headers);
    console.log("Request body keys:", Object.keys(req.body));

    try {
        // Use multer middleware to handle file upload
        upload.single("file")(req, res, async(err) => {
            if (err) {
                console.error("Multer error:", err);
                return res.status(400).json({
                    success: false,
                    message: "File upload error: " + err.message,
                });
            }

            // Check if file was uploaded
            if (!req.file) {
                return res.status(400).json({
                    success: false,
                    message: "No file uploaded. Please select a PDF file.",
                });
            }

            // Get file information
            const fileInfo = {
                originalName: req.file.originalname,
                filename: req.file.filename,
                path: req.file.path,
                size: req.file.size,
                mimetype: req.file.mimetype,
                uploadedAt: new Date(),
            };

            console.log("PDF uploaded successfully:", fileInfo);

            // Return success response immediately
            res.status(200).json({
                success: true,
                message: "PDF uploaded successfully!",
                file: {
                    filename: fileInfo.filename,
                    originalName: fileInfo.originalName,
                    size: fileInfo.size,
                    uploadedAt: fileInfo.uploadedAt,
                },
            });
        });
    } catch (error) {
        console.error("PDF upload error:", error);
        res.status(500).json({
            success: false,
            message: "Internal server error: " + error.message,
        });
    }
};

// Get all PDFs for a specific user
export const getUserPdfs = async(req, res) => {
    try {
        const { userId } = req.params;

        // Validate MongoDB ObjectId
        if (!mongoose.Types.ObjectId.isValid(userId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid user ID format",
            });
        }

        const pdfs = await PdfModel.find({ userId })
            .sort({ uploadedAt: -1 }) // Most recent first
            .select("-filePath"); // Exclude file path for security

        res.status(200).json({
            success: true,
            count: pdfs.length,
            pdfs: pdfs,
        });
    } catch (error) {
        console.error("Error fetching user PDFs:", error);
        res.status(500).json({
            success: false,
            message: "Internal server error: " + error.message,
        });
    }
};

// Get specific PDF by ID
export const getPdfById = async(req, res) => {
    try {
        const { id } = req.params;

        // Validate MongoDB ObjectId
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid PDF ID format",
            });
        }

        const pdf = await PdfModel.findById(id).select("-filePath"); // Exclude file path

        if (!pdf) {
            return res.status(404).json({
                success: false,
                message: "PDF not found",
            });
        }

        res.status(200).json({
            success: true,
            pdf: pdf,
        });
    } catch (error) {
        console.error("Error fetching PDF:", error);
        res.status(500).json({
            success: false,
            message: "Internal server error: " + error.message,
        });
    }
};

// Delete PDF by ID
export const deletePdf = async(req, res) => {
    try {
        const { id } = req.params;

        // Validate MongoDB ObjectId
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid PDF ID format",
            });
        }

        const pdf = await PdfModel.findById(id);

        if (!pdf) {
            return res.status(404).json({
                success: false,
                message: "PDF not found",
            });
        }

        // Delete the physical file
        try {
            if (fs.existsSync(pdf.filePath)) {
                fs.unlinkSync(pdf.filePath);
                console.log("Physical file deleted:", pdf.filePath);
            }
        } catch (fileError) {
            console.error("Error deleting physical file:", fileError);
            // Continue with database deletion even if file deletion fails
        }

        // Delete from database
        await PdfModel.findByIdAndDelete(id);

        res.status(200).json({
            success: true,
            message: "PDF deleted successfully",
        });
    } catch (error) {
        console.error("Error deleting PDF:", error);
        res.status(500).json({
            success: false,
            message: "Internal server error: " + error.message,
        });
    }
};