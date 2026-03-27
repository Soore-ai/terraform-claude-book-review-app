output "db_endpoint" {
  description = "Connection endpoint for the primary RDS instance"
  value       = aws_db_instance.primary.endpoint
}

output "db_host" {
  description = "Hostname of the primary RDS instance (without port)"
  value       = aws_db_instance.primary.address
}

output "db_port" {
  description = "Port of the primary RDS instance"
  value       = aws_db_instance.primary.port
}

output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.primary.db_name
}

output "read_replica_endpoint" {
  description = "Connection endpoint for the read replica"
  value       = aws_db_instance.read_replica.endpoint
}
