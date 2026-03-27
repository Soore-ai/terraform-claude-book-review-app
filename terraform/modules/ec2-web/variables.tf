variable "public_subnet_ids" {
  description = "List of public subnet IDs to launch web instances in"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security group ID for web tier instances"
  type        = string
}

variable "public_alb_tg_arn" {
  description = "ARN of the public ALB target group"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for web tier"
  type        = string
  default     = "t3.micro"
}

variable "internal_alb_dns" {
  description = "DNS name of the internal ALB (passed to frontend as API URL)"
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
