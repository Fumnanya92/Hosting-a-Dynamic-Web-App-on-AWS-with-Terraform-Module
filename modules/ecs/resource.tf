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
