output "public_alb_sg_id" {
  description = "Security group ID for the public ALB"
  value       = aws_security_group.public_alb.id
}

output "web_sg_id" {
  description = "Security group ID for web tier EC2 instances"
  value       = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  description = "Security group ID for the internal ALB"
  value       = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  description = "Security group ID for app tier EC2 instances"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security group ID for the RDS database"
  value       = aws_security_group.db.id
}
