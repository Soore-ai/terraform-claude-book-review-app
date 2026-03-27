# ------------------------------------------------------------------------------
# DB Subnet Group
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
    Tier        = "database"
  }
}

# ------------------------------------------------------------------------------
# RDS MySQL Primary Instance (Multi-AZ)
# ------------------------------------------------------------------------------
resource "aws_db_instance" "primary" {
  identifier     = "${var.project_name}-db-primary"
  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "book_review_db"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]

  publicly_accessible   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name        = "${var.project_name}-db-primary"
    Environment = var.environment
    Tier        = "database"
  }
}

# ------------------------------------------------------------------------------
# RDS MySQL Read Replica
# ------------------------------------------------------------------------------
resource "aws_db_instance" "read_replica" {
  identifier     = "${var.project_name}-db-replica"
  instance_class = var.db_instance_class
  storage_type   = "gp3"

  replicate_source_db = aws_db_instance.primary.identifier

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.project_name}-db-replica"
    Environment = var.environment
    Tier        = "database"
  }
}
