output "public_alb_dns" {
  description = "DNS name of the public ALB"
  value       = aws_lb.public.dns_name
}

output "public_alb_arn" {
  description = "ARN of the public ALB"
  value       = aws_lb.public.arn
}

output "public_alb_tg_arn" {
  description = "ARN of the web tier target group"
  value       = aws_lb_target_group.web.arn
}

output "internal_alb_dns" {
  description = "DNS name of the internal ALB"
  value       = aws_lb.internal.dns_name
}

output "internal_alb_arn" {
  description = "ARN of the internal ALB"
  value       = aws_lb.internal.arn
}

output "internal_alb_tg_arn" {
  description = "ARN of the app tier target group"
  value       = aws_lb_target_group.app.arn
}
