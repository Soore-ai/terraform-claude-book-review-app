output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public (web tier) subnets"
  value       = [aws_subnet.web_1.id, aws_subnet.web_2.id]
}

output "app_subnet_ids" {
  description = "IDs of the private (app tier) subnets"
  value       = [aws_subnet.app_1.id, aws_subnet.app_2.id]
}

output "db_subnet_ids" {
  description = "IDs of the private (database tier) subnets"
  value       = [aws_subnet.db_1.id, aws_subnet.db_2.id]
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gw_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}
