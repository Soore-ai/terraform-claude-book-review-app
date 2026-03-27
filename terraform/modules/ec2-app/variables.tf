variable "app_subnet_ids" {
  description = "List of private subnet IDs for app tier instances"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for app tier instances"
  type        = string
}

variable "internal_alb_tg_arn" {
  description = "ARN of the internal ALB target group"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for app tier"
  type        = string
  default     = "t3.micro"
}

variable "db_host" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret for the backend"
  type        = string
  sensitive   = true
}

variable "allowed_origins" {
  description = "Comma-separated list of allowed CORS origins"
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
