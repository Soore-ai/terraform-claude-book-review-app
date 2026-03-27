data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Subnets — Web Tier (Public)
# ------------------------------------------------------------------------------
resource "aws_subnet" "web_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az_a
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-web-subnet-1"
    Environment = var.environment
    Tier        = "web"
  }
}

resource "aws_subnet" "web_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az_b
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-web-subnet-2"
    Environment = var.environment
    Tier        = "web"
  }
}

# ------------------------------------------------------------------------------
# Subnets — App Tier (Private)
# ------------------------------------------------------------------------------
resource "aws_subnet" "app_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = local.az_a
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-app-subnet-1"
    Environment = var.environment
    Tier        = "app"
  }
}

resource "aws_subnet" "app_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = local.az_b
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-app-subnet-2"
    Environment = var.environment
    Tier        = "app"
  }
}

# ------------------------------------------------------------------------------
# Subnets — Database Tier (Private)
# ------------------------------------------------------------------------------
resource "aws_subnet" "db_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = local.az_a
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-db-subnet-1"
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_subnet" "db_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = local.az_b
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-db-subnet-2"
    Environment = var.environment
    Tier        = "database"
  }
}

# ------------------------------------------------------------------------------
# NAT Gateway (in public subnet for private subnet internet access)
# ------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_1.id

  tags = {
    Name        = "${var.project_name}-nat-gw"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------

# Public route table — routes to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Private route table — routes to NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Route Table Associations
# ------------------------------------------------------------------------------

# Public subnets (web tier)
resource "aws_route_table_association" "web_1" {
  subnet_id      = aws_subnet.web_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_2" {
  subnet_id      = aws_subnet.web_2.id
  route_table_id = aws_route_table.public.id
}

# Private subnets (app tier)
resource "aws_route_table_association" "app_1" {
  subnet_id      = aws_subnet.app_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "app_2" {
  subnet_id      = aws_subnet.app_2.id
  route_table_id = aws_route_table.private.id
}

# Private subnets (database tier)
resource "aws_route_table_association" "db_1" {
  subnet_id      = aws_subnet.db_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_2" {
  subnet_id      = aws_subnet.db_2.id
  route_table_id = aws_route_table.private.id
}
