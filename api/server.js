// server.js - entry point for the Inventory Integration API

const express = require('express');
const db = require('./db/db');
const inventoryRoutes = require('./routes/inventory');

const app = express();
const PORT = 3000;

app.use(express.json()); // parse JSON request bodies into req.body
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.url}`);
    next();
});
app.use('/api/inventory', inventoryRoutes);

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Inventory API is running' });
});

app.use((err, req, res, next) => {
    console.error(`[${new Date().toISOString()}] ERROR:`, err.message);
    res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
    console.log(`Inventory API listening on http://localhost:${PORT}`);
});