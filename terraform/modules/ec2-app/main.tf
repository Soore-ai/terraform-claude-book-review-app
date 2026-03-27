# ------------------------------------------------------------------------------
# Latest Ubuntu 22.04 LTS AMI
# ------------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# App Tier EC2 Instances (Private — NO public IP)
# ------------------------------------------------------------------------------
resource "aws_instance" "app_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.app_subnet_ids[0]
  vpc_security_group_ids      = [var.app_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/../../scripts/app-userdata.sh", {
    db_host         = var.db_host
    db_username     = var.db_username
    db_password     = var.db_password
    jwt_secret      = var.jwt_secret
    allowed_origins = var.allowed_origins
  })

  tags = {
    Name        = "${var.project_name}-app-1"
    Environment = var.environment
    Tier        = "app"
  }
}

resource "aws_instance" "app_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.app_subnet_ids[1]
  vpc_security_group_ids      = [var.app_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/../../scripts/app-userdata.sh", {
    db_host         = var.db_host
    db_username     = var.db_username
    db_password     = var.db_password
    jwt_secret      = var.jwt_secret
    allowed_origins = var.allowed_origins
  })

  tags = {
    Name        = "${var.project_name}-app-2"
    Environment = var.environment
    Tier        = "app"
  }
}

# ------------------------------------------------------------------------------
# Register instances with the Internal ALB Target Group
# ------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "app_1" {
  target_group_arn = var.internal_alb_tg_arn
  target_id        = aws_instance.app_1.id
  port             = 3001
}

resource "aws_lb_target_group_attachment" "app_2" {
  target_group_arn = var.internal_alb_tg_arn
  target_id        = aws_instance.app_2.id
  port             = 3001
}
