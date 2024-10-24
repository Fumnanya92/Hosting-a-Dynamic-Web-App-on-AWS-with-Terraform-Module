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
