# Book Review App — AWS Terraform Deployment

## Project Overview
This project deploys a **three-tier Book Review App** (Next.js + Node.js + MySQL) on AWS using Terraform. It follows production-grade infrastructure patterns for a DevOps assignment.

- **Repo**: https://github.com/pravinmishraaws/book-review-app.git
- **Frontend**: Next.js served via Nginx on port 80 (Ubuntu EC2 in public subnets)
- **Backend**: Node.js/Express API on port 3001 (EC2 in private subnets, no public IP)
- **Database**: Amazon RDS MySQL (Multi-AZ + Read Replica in private subnets)

## Architecture — Three Tiers

### Web Tier (Presentation)
- Ubuntu EC2 instances in **public subnets**
- Next.js built and served through **Nginx** reverse proxy on port 80
- Sits behind a **Public Application Load Balancer**
- Environment variable: `NEXT_PUBLIC_API_URL` pointing to the Internal ALB DNS

### App Tier (Business Logic)
- Ubuntu EC2 instances in **private subnets** — NO public IP, NO Elastic IP
- Node.js backend running on **port 3001** via PM2
- Sits behind an **Internal Application Load Balancer**
- Environment variables: `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`, `DB_DIALECT=mysql`, `JWT_SECRET`, `ALLOWED_ORIGINS`

### Database Tier (Data)
- **Amazon RDS for MySQL** in private subnets
- Multi-AZ enabled for high availability
- Read Replica enabled for read scaling
- Database name: `book_review_db`
- Only accessible from App Tier on port 3306

## Network Architecture
- **VPC CIDR**: `10.0.0.0/16`
- **6 subnets across 2 Availability Zones**:
  - Public Subnet 1 (Web): `10.0.1.0/24` (AZ-a)
  - Public Subnet 2 (Web): `10.0.2.0/24` (AZ-b)
  - Private Subnet 1 (App): `10.0.3.0/24` (AZ-a)
  - Private Subnet 2 (App): `10.0.4.0/24` (AZ-b)
  - Private Subnet 3 (DB): `10.0.5.0/24` (AZ-a)
  - Private Subnet 4 (DB): `10.0.6.0/24` (AZ-b)
- **Internet Gateway** for public subnets
- **NAT Gateway** in a public subnet for outbound internet from private subnets

## Security Groups
- **Web SG**: Inbound HTTP (80) from anywhere, SSH (22) from your IP only
- **App SG**: Inbound 3001 from Web SG only, SSH (22) from bastion/web tier
- **DB SG**: Inbound 3306 from App SG only
- **ALB SGs**: Public ALB allows 80 from anywhere; Internal ALB allows 3001 from Web SG

## Terraform Conventions
- Use **HCL** (not JSON) for all `.tf` files
- Organize code into modules: `modules/vpc`, `modules/security-groups`, `modules/alb`, `modules/ec2-web`, `modules/ec2-app`, `modules/rds`
- Use `variables.tf` and `outputs.tf` in every module
- Use `terraform.tfvars` for environment-specific values
- Always run `terraform fmt` and `terraform validate` before committing
- State stored locally (no remote backend required for this assignment)
- Provider: `hashicorp/aws` — use latest stable version
- Region: `us-east-1` (default, configurable via variable)

## Workflow
1. `terraform init` — Initialize providers and modules
2. `terraform fmt -recursive` — Format all files
3. `terraform validate` — Check syntax and configuration
4. `terraform plan -out=tfplan` — Review changes before applying
5. `terraform apply tfplan` — Apply the plan
6. Test connectivity: Public ALB → Web Tier → Internal ALB → App Tier → RDS
7. `terraform destroy` — Tear down when done

## Key Files
```
/terraform
├── main.tf              # Root module, calls child modules
├── variables.tf         # Root variables
├── outputs.tf           # Root outputs (ALB DNS, RDS endpoint)
├── terraform.tfvars     # Variable values (DO NOT commit secrets)
├── providers.tf         # AWS provider config
├── modules/
│   ├── vpc/             # VPC, subnets, IGW, NAT, route tables
│   ├── security-groups/ # All SGs for web, app, db, ALBs
│   ├── alb/             # Public ALB + Internal ALB
│   ├── ec2-web/         # Web tier EC2 + user_data script
│   ├── ec2-app/         # App tier EC2 + user_data script
│   └── rds/             # RDS primary + read replica
├── scripts/
│   ├── web-userdata.sh  # Bootstrap script for web tier EC2
│   └── app-userdata.sh  # Bootstrap script for app tier EC2
```

## Common Errors and Fixes
- **"No available AZ"**: Ensure subnets use valid AZs like `us-east-1a` and `us-east-1b`
- **RDS subnet group error**: DB subnet group needs subnets in at least 2 AZs
- **App can't reach DB**: Check DB SG allows 3306 from App SG, and RDS is in same VPC
- **Frontend can't reach backend**: Verify `NEXT_PUBLIC_API_URL` points to Internal ALB DNS with correct port
- **Timeout on EC2 user_data**: Check NAT Gateway is routing correctly for private subnet instances

## Important Rules
- NEVER assign public IPs to App Tier or DB Tier resources
- NEVER hardcode secrets in Terraform files — use variables or AWS Secrets Manager
- ALWAYS tag resources with `Project = "book-review-app"` and `Environment = "production"`
- ALWAYS validate security group rules restrict access to the minimum required
- When debugging, check CloudWatch logs and EC2 instance console output first
