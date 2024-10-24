const express = require('express');
const taskRoutes = require('./routes/taskRoutes');
require('dotenv').config();
const path = require('path');

const app = express();
const port = 3000;

app.use(express.json()); // Middleware to parse JSON
app.use('/tasks', taskRoutes); // Routes for task management
app.use(express.static(path.join(__dirname, 'public'))); // Serve static files

// Default route for root URL
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html')); // Serve the index.html
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
