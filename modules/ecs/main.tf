# Declare input variables for the ECS module
variable "existing_vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "existing_subnet_ids" {
  description = "The list of existing Subnet IDs"
  type        = list(string)
}

variable "existing_security_group_id" {
  description = "The ID of the existing Security Group"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the IAM Policy for ECS Task Execution Role
resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecsTaskExecutionPolicyAttachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Define ECS Cluster
resource "aws_ecs_cluster" "webapp_cluster" {
  name = "webapp-cluster"
}

# Outputs
output "cluster_name" {
  value = aws_ecs_cluster.webapp_cluster.name
}

# Define ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "task-manager-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"  # Keep this as awsvpc
  
  cpu     = "1024"  # 1 vCPU (1024 CPU shares)
  memory  = "3072"  # 3 GB (3072 MiB)

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn  # Add execution role ARN

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.ecr_repository_url
      cpu       = 1024  # 1 vCPU
      memory    = 3072  # 3 GB
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        },
      ]
    }
  ])
}

# Define key pair and local file for SSH access
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "example_keypair" {
  key_name   = "tfkey"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "tf_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "tfkey"
}

# Fetch the latest ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Define EC2 instance for ECS
resource "aws_instance" "ecs_instance" {
  ami                    = data.aws_ssm_parameter.ecs_ami.value
  instance_type         = "t2.micro"  # Adjust as needed
  key_name              = aws_key_pair.example_keypair.key_name

  tags = {
    Name = "ecs-instance"
  }
}

# Define ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my_service1"
  cluster         = aws_ecs_cluster.webapp_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"  # Ensure Fargate is set

  network_configuration {
    subnets          = var.existing_subnet_ids
    security_groups  = [var.existing_security_group_id]
    assign_public_ip = true # or "DISABLED" based on your needs
  }
}