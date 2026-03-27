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
# Web Tier EC2 Instances
# ------------------------------------------------------------------------------
resource "aws_instance" "web_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/../../scripts/web-userdata.sh", {
    internal_alb_dns = var.internal_alb_dns
  })

  tags = {
    Name        = "${var.project_name}-web-1"
    Environment = var.environment
    Tier        = "web"
  }
}

resource "aws_instance" "web_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_pair_name

  user_data = templatefile("${path.module}/../../scripts/web-userdata.sh", {
    internal_alb_dns = var.internal_alb_dns
  })

  tags = {
    Name        = "${var.project_name}-web-2"
    Environment = var.environment
    Tier        = "web"
  }
}

# ------------------------------------------------------------------------------
# Register instances with the Public ALB Target Group
# ------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = var.public_alb_tg_arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = var.public_alb_tg_arn
  target_id        = aws_instance.web_2.id
  port             = 80
}
