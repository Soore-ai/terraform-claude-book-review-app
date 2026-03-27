# ==============================================================================
# Root Outputs — Key values for testing and documentation
# ==============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_alb_dns" {
  description = "DNS name of the public ALB — access the app at http://<this-value>"
  value       = module.alb.public_alb_dns
}

output "internal_alb_dns" {
  description = "DNS name of the internal ALB (used by web tier to reach app tier)"
  value       = module.alb.internal_alb_dns
}

output "rds_endpoint" {
  description = "Endpoint of the primary RDS MySQL instance"
  value       = module.rds.db_endpoint
}

output "rds_read_replica_endpoint" {
  description = "Endpoint of the RDS read replica"
  value       = module.rds.read_replica_endpoint
}

output "web_instance_ids" {
  description = "Instance IDs of the web tier EC2s"
  value       = module.ec2_web.instance_ids
}

output "web_instance_public_ips" {
  description = "Public IPs of the web tier EC2s (for SSH access)"
  value       = module.ec2_web.instance_public_ips
}

output "app_instance_ids" {
  description = "Instance IDs of the app tier EC2s"
  value       = module.ec2_app.instance_ids
}
