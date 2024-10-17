# Mini Project: Hosting a Dynamic Web App on AWS with Terraform Module, Docker, Amazon ECR, and ECS

## Purpose
In this project, you will use Terraform to create a modular infrastructure for hosting a dynamic web application on Amazon ECS (Elastic Container Service). You will containerize the web application using Docker, push the Docker image to Amazon ECR (Elastic Container Registry), and deploy the app on ECS.

---

## Project Tasks

### Task 1: Dockerization of Web App
1. **Create a dynamic web application**  
   Use a technology of your choice (e.g., Node.js, Flask, Django) to build the web app.

2. **Write a Dockerfile**  
   Create a Dockerfile to containerize the web application. Example for Node.js:

   ```dockerfile
   FROM node:14

   WORKDIR /app

   COPY package*.json ./

   RUN npm install

   COPY . .

   EXPOSE 3000

   CMD ["npm", "start"]
   ```

3. **Test the Docker image locally**  
   Build and run the Docker image locally to verify that the web app runs correctly within the container:
   ```bash
   docker build -t my-webapp .
   docker run -p 3000:3000 my-webapp
   ```

---

### Task 2: Terraform Module for Amazon ECR
1. **Create a directory for your Terraform project**  
   Open a terminal and run:
   ```bash
   mkdir terraform-ecs-webapp
   cd terraform-ecs-webapp
   ```

2. **Create a directory for the Amazon ECR module**  
   Inside the project directory, create the directory:
   ```bash
   mkdir -p modules/ecr
   ```

3. **Write the ECR module**  
   Create a file `modules/ecr/main.tf` to create an Amazon ECR repository:
   ```hcl
   resource "aws_ecr_repository" "webapp_repo" {
     name                 = "your-webapp-repo"
     image_tag_mutability = "MUTABLE"
     image_scanning_configuration {
       scan_on_push = true
     }
   }

   output "repository_url" {
     value = aws_ecr_repository.webapp_repo.repository_url
   }
   ```

---

### Task 3: Terraform Module for ECS
1. **Create a directory for the ECS module**  
   Inside the project directory, run:
   ```bash
   mkdir -p modules/ecs
   ```

2. **Write the ECS module**  
   Create a file `modules/ecs/main.tf` to provision an ECS cluster and deploy the Dockerized web app:
   ```hcl
   resource "aws_ecs_cluster" "webapp_cluster" {
     name = "webapp-cluster"
   }

   # ECS Task Definition and Service configuration would go here

   output "cluster_name" {
     value = aws_ecs_cluster.webapp_cluster.name
   }
   ```

---

### Task 4: Main Terraform Configuration
1. **Create the main Terraform configuration file**  
   In the project directory, create the file `main.tf` and use the ECR and ECS modules:
   ```hcl
   module "ecr" {
     source          = "./modules/ecr"
     repository_name = "your-webapp-repo"
   }

   module "ecs" {
     source             = "./modules/ecs"
     ecr_repository_url = module.ecr.repository_url
   }
   ```

---

### Task 5: Deployment
1. **Build the Docker image**  
   Build the Docker image of your web app:
   ```bash
   docker build -t your-webapp .
   ```

2. **Push the Docker image to ECR**  
   Use the following commands to tag and push the image to ECR (replace with actual repository URL):
   ```bash
   $(aws ecr get-login --no-include-email --region <your-region>)
   docker tag your-webapp:latest <repository-url>:latest
   docker push <repository-url>:latest
   ```

3. **Deploy the ECS cluster and web app**  
   Run the following Terraform commands to deploy the infrastructure:
   ```bash
   terraform init
   terraform apply
   ```

4. **Access the web app**  
   Once deployment is complete, access the web app via the public IP or DNS of the ECS service.

---

## Observations and Challenges
