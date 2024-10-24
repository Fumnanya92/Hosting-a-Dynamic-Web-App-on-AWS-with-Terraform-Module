const express = require('express');
const { getAllTasks, createTask, updateTask, deleteTask } = require('../controllers/taskController');

const router = express.Router();

router.get('/', getAllTasks);
router.post('/', createTask);
router.put('/:taskId', updateTask);
router.delete('/:taskId', deleteTask);

module.exports = router;
