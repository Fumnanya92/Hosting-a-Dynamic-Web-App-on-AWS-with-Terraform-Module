const { getTasksFromDB, createTaskInDB, updateTaskInDB, deleteTaskFromDB } = require('../services/dynamoService');

// Get all tasks
exports.getAllTasks = async (req, res) => {
    try {
        const tasks = await getTasksFromDB();
        res.status(200).json(tasks);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Create a new task
exports.createTask = async (req, res) => {
    const { taskId, taskName, dueDate, status } = req.body;
    try {
        const newTask = await createTaskInDB({ taskId, taskName, dueDate, status });
        res.status(201).json(newTask);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Update a task
exports.updateTask = async (req, res) => {
    const { taskId } = req.params;
    const { taskName, dueDate, status } = req.body;
    try {
        const updatedTask = await updateTaskInDB(taskId, { taskName, dueDate, status });
        res.status(200).json(updatedTask);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete a task
exports.deleteTask = async (req, res) => {
    const { taskId } = req.params;
    try {
        await deleteTaskFromDB(taskId);
        res.status(204).end();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
