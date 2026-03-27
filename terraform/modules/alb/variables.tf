variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the public ALB"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "List of app subnet IDs for the internal ALB"
  type        = list(string)
}

variable "public_alb_sg_id" {
  description = "Security group ID for the public ALB"
  type        = string
}

variable "internal_alb_sg_id" {
  description = "Security group ID for the internal ALB"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}
