import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';

// Create a simple test PDF file
const createTestPdf = async() => {
    const testDir = path.join(process.cwd(), 'test-files');
    const testPdfPath = path.join(testDir, 'test-webhook.pdf');

    // Create directory if it doesn't exist
    if (!fs.existsSync(testDir)) {
        fs.mkdirSync(testDir, { recursive: true });
    }

    // Create a simple PDF-like file
    fs.writeFileSync(testPdfPath, '%PDF-1.5\nThis is a test PDF file for n8n webhook testing.\n');

    console.log(`Test PDF created at: ${testPdfPath}`);
    return testPdfPath;
};

// Test the webhook directly
const testWebhookDirectly = async() => {
    try {
        console.log('Testing n8n webhook directly...');

        // Create test PDF file
        const testPdfPath = await createTestPdf();
        console.log(`File exists: ${fs.existsSync(testPdfPath)}`);
        console.log(`File size: ${fs.statSync(testPdfPath).size} bytes`);

        // Create form data
        const form = new FormData();
        form.append('email', 'test@example.com');

        // Add file to form data
        const fileStream = fs.createReadStream(testPdfPath);
        form.append('file', fileStream, {
            filename: 'test-webhook.pdf',
            contentType: 'application/pdf'
        });

        console.log('Form data created with headers:', form.getHeaders());

        // Send to n8n webhook
        console.log('Sending request to n8n webhook...');
        const webhookUrl = 'https://dhruv-chotai-10.app.n8n.cloud/webhook/send-financial-report';

        const response = await axios.post(
            webhookUrl,
            form, {
                headers: {
                    ...form.getHeaders(),
                    'Accept': 'application/json'
                },
                timeout: 30000,
                maxContentLength: Infinity,
                maxBodyLength: Infinity
            }
        );

        console.log('✅ Webhook triggered successfully!');
        console.log('Status:', response.status);
        console.log('Response:', response.data);

    } catch (error) {
        console.error('❌ Error testing webhook:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        } else {
            console.error('Full error:', error);
        }
    }
};

// Run the test
testWebhookDirectly();