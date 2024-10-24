resource "aws_ecs_cluster" "webapp_cluster" {
  name = "webapp-cluster"
}

# ECS Task Definition and Service configuration would go here

output "cluster_name" {
  value = aws_ecs_cluster.webapp_cluster.name
}

variable "ecr_repository_url" {
  type = string
}

resource "aws_ecs_task_definition" "app" {
  family                   = "task-manager-app"
  container_definitions    = jsonencode([{
    name      = "app"
    image     = var.ecr_repository_url  # Use the passed ECR URL here
    essential = true
    memory    = 512
    cpu       = 256
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}