resource "aws_ecr_repository" "webapp_repo" {
  name                 = "task-manager-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.webapp_repo.repository_url
}

variable "repository_name" {
  type = string
}

#resource "aws_ecr_repository" "webapp_repo" {
#  name = var.repository_name
#}
