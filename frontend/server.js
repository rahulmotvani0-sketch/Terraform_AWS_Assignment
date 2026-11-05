const express = require('express');
const axios = require('axios');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:5000';

// Middleware
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Configure EJS view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        service: 'express-frontend',
        port: PORT,
        backend_target: BACKEND_URL,
        timestamp: new Date().toISOString()
    });
});

// Home Page: renders the input form
app.get('/', (req, res) => {
    res.render('index', {
        backendUrl: BACKEND_URL,
        error: null,
        success: null
    });
});

// Form Submission: proxies request to Flask backend
app.post('/submit', async (req, res) => {
    const { name, email, course, message, priority } = req.body;

    if (!name || !email) {
        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.status(400).json({ status: 'error', message: 'Name and Email are required fields.' });
        }
        return res.render('index', {
            backendUrl: BACKEND_URL,
            error: 'Name and Email are required fields.',
            success: null
        });
    }

    const payload = {
        name,
        email,
        course: course || 'DevOps Engineering',
        message: message || '',
        priority: priority || 'Medium',
        submitted_via: 'Node.js/Express Frontend',
        client_timestamp: new Date().toISOString()
    };

    try {
        console.log(`[Frontend] Forwarding submission to Flask backend at ${BACKEND_URL}/process...`);
        const response = await axios.post(`${BACKEND_URL}/process`, payload, {
            headers: { 'Content-Type': 'application/json' },
            timeout: 5000
        });

        console.log('[Frontend] Backend response received:', response.data);

        // If client requested JSON (AJAX)
        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.status(200).json(response.data);
        }

        // Render result page with response data
        res.render('result', {
            result: response.data,
            submittedData: payload,
            backendUrl: BACKEND_URL
        });
    } catch (err) {
        console.error('[Frontend] Error forwarding to Flask backend:', err.message);
        const errorMsg = err.response && err.response.data && err.response.data.message
            ? err.response.data.message
            : `Failed to communicate with Flask backend at ${BACKEND_URL}. Ensure the backend service is running.`;

        if (req.headers.accept && req.headers.accept.includes('application/json')) {
            return res.status(502).json({ status: 'error', message: errorMsg });
        }

        res.render('index', {
            backendUrl: BACKEND_URL,
            error: errorMsg,
            success: null
        });
    }
});

// View all submissions from Flask backend
app.get('/submissions', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/submissions`, { timeout: 5000 });
        res.render('submissions', {
            submissions: response.data.submissions || [],
            total: response.data.total || 0,
            backendUrl: BACKEND_URL
        });
    } catch (err) {
        console.error('[Frontend] Error fetching submissions:', err.message);
        res.render('submissions', {
            submissions: [],
            total: 0,
            error: `Unable to fetch submissions from ${BACKEND_URL}.`,
            backendUrl: BACKEND_URL
        });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`=======================================================`);
    console.log(`🚀 Node.js/Express Frontend running on http://0.0.0.0:${PORT}`);
    console.log(`🔗 Target Flask Backend URL: ${BACKEND_URL}`);
    console.log(`=======================================================`);
});

