# ==============================================================================
# Book Review App — Root Module
# Wires all child modules together in dependency order
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Networking — VPC, Subnets, IGW, NAT, Route Tables
# ------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}

# ------------------------------------------------------------------------------
# 2. Security Groups — Tier-specific access controls
# ------------------------------------------------------------------------------
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
  project_name = var.project_name
  environment  = var.environment
}

# ------------------------------------------------------------------------------
# 3. Load Balancers — Public ALB (web) + Internal ALB (app)
# ------------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  app_subnet_ids     = module.vpc.app_subnet_ids
  public_alb_sg_id   = module.security_groups.public_alb_sg_id
  internal_alb_sg_id = module.security_groups.internal_alb_sg_id
  project_name       = var.project_name
  environment        = var.environment
}

# ------------------------------------------------------------------------------
# 4. Database — RDS MySQL Primary (Multi-AZ) + Read Replica
#    Created before EC2 app tier so the endpoint is available for user_data
# ------------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  db_subnet_ids     = module.vpc.db_subnet_ids
  db_sg_id          = module.security_groups.db_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  project_name      = var.project_name
  environment       = var.environment
}

# ------------------------------------------------------------------------------
# 5. Web Tier — EC2 instances running Next.js + Nginx
# ------------------------------------------------------------------------------
module "ec2_web" {
  source = "./modules/ec2-web"

  public_subnet_ids = module.vpc.public_subnet_ids
  web_sg_id         = module.security_groups.web_sg_id
  public_alb_tg_arn = module.alb.public_alb_tg_arn
  key_pair_name     = var.key_pair_name
  instance_type     = var.instance_type_web
  internal_alb_dns  = module.alb.internal_alb_dns
  project_name      = var.project_name
  environment       = var.environment
}

# ------------------------------------------------------------------------------
# 6. App Tier — EC2 instances running Node.js backend
# ------------------------------------------------------------------------------
module "ec2_app" {
  source = "./modules/ec2-app"

  app_subnet_ids      = module.vpc.app_subnet_ids
  app_sg_id           = module.security_groups.app_sg_id
  internal_alb_tg_arn = module.alb.internal_alb_tg_arn
  key_pair_name       = var.key_pair_name
  instance_type       = var.instance_type_app
  db_host             = module.rds.db_host
  db_username         = var.db_username
  db_password         = var.db_password
  jwt_secret          = var.jwt_secret
  allowed_origins     = "http://${module.alb.public_alb_dns}"
  project_name        = var.project_name
  environment         = var.environment
}
