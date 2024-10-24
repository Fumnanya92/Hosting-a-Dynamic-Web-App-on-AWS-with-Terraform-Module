// public/script.js
const taskForm = document.getElementById('taskForm');
const taskInput = document.getElementById('taskInput');
const taskList = document.getElementById('taskList');

// Fetch and display tasks
async function fetchTasks() {
    const response = await fetch('/tasks');
    const tasks = await response.json();
    taskList.innerHTML = ''; // Clear existing tasks
    tasks.forEach(task => {
        const taskDiv = document.createElement('div');
        taskDiv.classList.add('task');
        taskDiv.innerHTML = `
            ${task.taskName}
            <button class="delete" onclick="deleteTask('${task.taskId}')">Delete</button>
        `;
        taskList.appendChild(taskDiv);
    });
}

// Add a new task
taskForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    const newTask = {
        taskId: Date.now().toString(), // Simple ID generation
        taskName: taskInput.value,
        status: 'pending',
    };
    await fetch('/tasks', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTask),
    });
    taskInput.value = ''; // Clear input
    fetchTasks(); // Refresh task list
});

// Delete a task
async function deleteTask(taskId) {
    await fetch(`/tasks/${taskId}`, {
        method: 'DELETE',
    });
    fetchTasks(); // Refresh task list
}

// Initial fetch of tasks
fetchTasks();
