output "instance_ids" {
  description = "IDs of the web tier EC2 instances"
  value       = [aws_instance.web_1.id, aws_instance.web_2.id]
}

output "instance_public_ips" {
  description = "Public IP addresses of the web tier instances"
  value       = [aws_instance.web_1.public_ip, aws_instance.web_2.public_ip]
}
