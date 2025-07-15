const express = require('express');
const WebSocket = require('ws');
const http = require('http');
const path = require('path');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Serve static files from public directory
app.use(express.static(path.join(__dirname, '../public')));

// WebSocket server for real-time communication
const wss = new WebSocket.Server({ server, path: '/ws' });

// Store latest 50 messages
let recentMessages = [];
const MAX_MESSAGES = 50;

// WebSocket connection handler
wss.on('connection', (ws) => {
    console.log('New WebSocket connection established');
    
    // Send existing messages to new client
    ws.send(JSON.stringify({
        type: 'initial_messages',
        messages: recentMessages
    }));
    
    ws.on('close', () => {
        console.log('WebSocket connection closed');
    });
});

// Function to add new message and broadcast to all clients
function addMessage(message) {
    recentMessages.push(message);
    
    // Keep only the latest 50 messages
    if (recentMessages.length > MAX_MESSAGES) {
        recentMessages.shift();
    }
    
    // Broadcast to all connected clients
    const messageData = JSON.stringify({
        type: 'new_message',
        message: message
    });
    
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(messageData);
        }
    });
}

// REST API endpoint to receive messages from Java application
app.post('/api/message', (req, res) => {
    const { username, message, timestamp } = req.body;
    
    if (!username || !message || !timestamp) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const messageObj = {
        username,
        message,
        timestamp,
        id: Date.now() + Math.random() // Simple unique ID
    };
    
    addMessage(messageObj);
    console.log(`[${timestamp}] ${username}: ${message}`);
    
    res.json({ success: true });
});

// API endpoint to get recent messages
app.get('/api/messages', (req, res) => {
    res.json(recentMessages);
});

// Root route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Chat viewer server running on http://0.0.0.0:${PORT}`);
    console.log(`WebSocket server running on ws://0.0.0.0:${PORT}/ws`);
});

module.exports = { addMessage };