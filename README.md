Here's the full documentation for your project, **"Hosting a Dynamic Web App on AWS with Terraform, Docker, Amazon ECR, and ECS"**, including setup, testing, and error correction. The documentation will cover all the steps you followed in the project from the initial app creation to deployment on AWS.

---

# Task Management App Deployment on AWS with Docker, Terraform, and ECS

## Table of Contents
1. [Introduction](#introduction)
2. [Project Setup](#project-setup)
3. [Building the Task Management App](#building-the-task-management-app)
4. [Dockerizing the Application](#dockerizing-the-application)
5. [Terraform Modules for ECR and ECS](#terraform-modules-for-ecr-and-ecs)
6. [Main Terraform Configuration](#main-terraform-configuration)
7. [Deploying the Application](#deploying-the-application)
8. [Testing the Deployment](#testing-the-deployment)
9. [Error Handling](#error-handling)
10. [Conclusion and Next Steps](#conclusion-and-next-steps)

---

## Introduction

In this project, you will host a dynamic Task Management App on AWS using Docker and Amazon ECS. The app will be containerized using Docker, stored in Amazon ECR, and deployed on ECS using Terraform. The goal is to showcase how to use Infrastructure as Code (IaC) and containerized applications for a production-ready deployment.

---

## Project Setup

### Prerequisites
1. Install **Node.js**, **Docker**, **AWS CLI**, and **Terraform**.
2. Set up AWS credentials using `aws configure` for programmatic access.
3. Ensure your AWS IAM role has permissions to create and manage ECS, ECR, and DynamoDB resources.

### Directory Structure

Create the following directory structure for your project:

```
task-manager-app/
│
├── app.js               # Main application file
├── routes/
│   └── taskRoutes.js    # API routes for tasks
├── controllers/
│   └── taskController.js # Task controller to handle business logic
├── services/
│   └── dynamoService.js  # Service to interact with DynamoDB
├── models/
│   └── taskModel.js      # Task model (optional)
├── .env                 # Environment variables
└── package.json
```

---

## Building the Task Management App

### 1.1. Initialize Node.js Project
```bash
mkdir task-manager-app
cd task-manager-app
npm init -y
npm install express aws-sdk dotenv
```

### 1.2. App.js
This file sets up the Express server and routes.

```javascript
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

```

### 1.3. DynamoDB Setup
Create a DynamoDB table named `Tasks` with the following configuration:

```bash
aws dynamodb create-table \
    --table-name Tasks \
    --attribute-definitions AttributeName=taskId,AttributeType=S \
    --key-schema AttributeName=taskId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 1.4. Task Controller (controllers/taskController.js)
```javascript

exports.getAllTasks = async (req, res) => {
    try {const { getTasksFromDB, createTaskInDB, updateTaskInDB, deleteTaskFromDB } = require('../services/dynamoService');

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

```

### 1.5. DynamoDB Service (services/dynamoService.js)
```javascript
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, PutCommand, UpdateCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');
require('dotenv').config();

// Create DynamoDB client
const client = new DynamoDBClient({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
});

const dynamoDB = DynamoDBDocumentClient.from(client);
const tableName = process.env.DYNAMO_TABLE_NAME;

// Get all tasks
exports.getTasksFromDB = async () => {
    const params = {
        TableName: tableName,
    };
    const command = new ScanCommand(params);
    const data = await dynamoDB.send(command);
    return data.Items;
};

// Create a task
exports.createTaskInDB = async (task) => {
    const params = {
        TableName: tableName,
        Item: task,
    };
    const command = new PutCommand(params);
    await dynamoDB.send(command);
    return task;
};

// Update a task
exports.updateTaskInDB = async (taskId, task) => {
    const params = {
        TableName: tableName,
        Key: { taskId },
        UpdateExpression: 'set taskName = :n, dueDate = :d, status = :s',
        ExpressionAttributeValues: {
            ':n': task.taskName,
            ':d': task.dueDate,
            ':s': task.status,
        },
        ReturnValues: 'UPDATED_NEW',
    };
    const command = new UpdateCommand(params);
    const data = await dynamoDB.send(command);
    return data.Attributes;
};

// Delete a task
exports.deleteTaskFromDB = async (taskId) => {
    const params = {
        TableName: tableName,
        Key: { taskId },
    };
    const command = new DeleteCommand(params);
    await dynamoDB.send(command);
};


// Add createTaskInDB, updateTaskInDB, and deleteTaskFromDB similarly
```

---

## Dockerizing the Application

### Dockerfile
Create a `Dockerfile` in the root of your project:

```dockerfile
FROM node:14

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Build and Test the Docker Image

```bash
docker build -t task-manager-app .
docker run -p 3000:3000 task-manager-app
```

---

## Terraform Modules for ECR and ECS

### ECR Module (modules/ecr/main.tf)
```hcl
resource "aws_ecr_repository" "webapp_repo" {
  name = "task-manager-app"
}
```

### ECS Module (modules/ecs/main.tf)
```hcl
resource "aws_ecs_cluster" "webapp_cluster" {
  name = "webapp-cluster"
}

// Add ECS service and task definition
```

---

## Main Terraform Configuration

### Main Configuration (main.tf)
```hcl
module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
  ecr_repository_url = module.ecr.repository_url
}

provider "aws" {
  region = "us-west-2"
}
```

### Apply the Configuration

```bash
terraform init
terraform apply
```

---

## Deploying the Application

1. **Tag and Push Docker Image to ECR**
   ```bash
   $(aws ecr get-login --no-include-email --region us-west-2)
   docker tag task-manager-app:latest 571600860285.dkr.ecr.us-west-2.amazonaws.com/task-manager-app:latest
   docker push 571600860285.dkr.ecr.us-west-2.amazonaws.com/task-manager-app:latest
   ```

2. **Deploy ECS Cluster and Service**
   Run the following Terraform command:
   ```bash
   terraform apply
   ```

---

## Testing the Deployment

- Access the ECS Service through the public IP or DNS name provided after deployment.
- Use a tool like **Postman** or **curl** to test API endpoints (`GET /tasks`, `POST /tasks`, etc.).

---

## Error Handling

- **ECR Push Error (Denied: requested access to the resource is denied)**: Ensure you are tagging the Docker image with the correct repository URL.
- **DynamoDB Error**: Check if your AWS credentials are set correctly in the `.env` file.
- **Terraform Unsupported Argument**: Double-check module variables and ensure your Terraform version is up to date.

---

## Conclusion and Next Steps

You’ve successfully built, containerized, and deployed a Task Management App on AWS using Docker, ECS, and Terraform. Future improvements could include:

1. **User authentication** for tasks.
2. **Enhanced error handling** in the Node.js app.
3. **Monitoring** and **auto-scaling** features in ECS for production readiness.
