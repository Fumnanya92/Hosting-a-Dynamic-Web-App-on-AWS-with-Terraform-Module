terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "task-manager-app"
}

module "ecs" {
  source                     = "./modules/ecs" # Point to the module directory
  ecr_repository_url         = module.ecr.repository_url
  existing_vpc_id            = var.existing_vpc_id
  existing_subnet_ids        = var.existing_subnet_ids
  existing_security_group_id = var.existing_security_group_id
}
