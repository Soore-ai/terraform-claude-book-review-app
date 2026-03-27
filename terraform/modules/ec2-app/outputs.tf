output "instance_ids" {
  description = "IDs of the app tier EC2 instances"
  value       = [aws_instance.app_1.id, aws_instance.app_2.id]
}
