# Three-Tier Book Review App — AWS Infrastructure Deployment

A production-style three-tier web application deployed on AWS using Terraform. This project demonstrates end-to-end cloud infrastructure design — from custom VPC architecture to multi-AZ database replication — with a focus on security, high availability, and infrastructure as code.

> **Infrastructure by:** Ed Eguaikhide  
> **Portfolio:** [sites.google.com/view/edeguaikhide](https://sites.google.com/view/edeguaikhide)  
> **Writeup:** [View on Medium] (https://medium.com/@eguaikhidee/i-deployed-a-three-tier-app-on-aws-with-terraform-heres-what-actually-broke-be34184f22d7)

---

## Architecture Overview

![Architecture Diagram](./architecture/book-review-app-architecture.png)

The application is deployed across **two Availability Zones** in a custom VPC, with three fully isolated tiers:

| Tier | Layer | Resources |
|---|---|---|
| Web | Public Subnets (10.0.1.0/24, 10.0.2.0/24) | EC2 (Next.js + Nginx), Public ALB |
| App | Private Subnets (10.0.3.0/24, 10.0.4.0/24) | EC2 (Node.js :3001), Internal ALB |
| DB | Private Subnets (10.0.5.0/24, 10.0.6.0/24) | RDS MySQL (Multi-AZ + Read Replica) |

**Traffic flow:**
```
Users → Internet Gateway → Public ALB → Web EC2 (Nginx → Next.js)
                                              ↓
                                        Internal ALB → App EC2 (Node.js)
                                                             ↓
                                                       RDS MySQL (Primary)
                                                             ↓
                                                    RDS Read Replica (standby)
```

---

## Infrastructure Built

- **VPC** — Custom `10.0.0.0/16` with 6 subnets across 2 AZs
- **Internet Gateway** — Public traffic entry point
- **NAT Gateway** — Allows private subnets to reach the internet for updates without public exposure
- **2 Application Load Balancers** — Public ALB (web tier) + Internal ALB (app tier)
- **4 EC2 Instances** — 2 web + 2 app, spread across AZs for redundancy
- **5 Security Groups** — Enforcing strict tier-to-tier access controls
- **RDS MySQL Multi-AZ** — Primary with automatic failover
- **RDS Read Replica** — Separate read endpoint for scalability
- **Route Tables** — Public and private routing with proper associations

**Total resources provisioned via Terraform: 33**

---

## Security Design

Security group rules enforce strict least-privilege access between tiers:

```
Public ALB     → Web EC2     : HTTP port 80 only
Web EC2        → Internal ALB: port 3001 only
Internal ALB   → App EC2     : port 3001 only
App EC2        → RDS MySQL   : port 3306 only

Web EC2 → RDS : BLOCKED (verified via connection timeout test)
Internet → Internal ALB : BLOCKED (internal-only DNS)
RDS : not publicly accessible
App EC2 : no public IP assigned
```

Security was validated by:
- Confirming app tier targets were reachable only through the internal ALB
- Verifying the RDS endpoint timed out from the web tier
- Confirming the internal ALB DNS was unreachable from the public internet

---

## Tech Stack

**Application**
- Frontend: Next.js, Tailwind CSS, Axios, React Context API
- Backend: Node.js, Express.js, Sequelize ORM
- Database: MySQL

**Infrastructure**
- IaC: Terraform (33 resources)
- Compute: AWS EC2 (Ubuntu, t3.micro)
- Networking: VPC, ALB, IGW, NAT Gateway, Route Tables, Security Groups
- Database: Amazon RDS MySQL (Multi-AZ + Read Replica)
- Process Management: PM2 (Node.js backend)
- Web Server: Nginx (reverse proxy)

---

## Project Structure

```
book-review-app/
├── frontend/               # Next.js frontend application
│   ├── src/
│   │   ├── app/            # Pages (home, book detail, login, register)
│   │   ├── components/     # Reusable UI components
│   │   ├── context/        # React auth state management
│   │   └── services/       # Axios API functions
│   └── package.json
├── backend/                # Node.js + Express API
│   ├── src/
│   │   ├── config/         # Database connection
│   │   ├── models/         # Sequelize models (User, Book, Review)
│   │   ├── routes/         # Express route handlers
│   │   ├── controllers/    # Business logic
│   │   └── middleware/     # JWT auth middleware
│   └── package.json
├── terraform/              # All infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars    # Your values (DO NOT COMMIT)
│   └── modules/
│       ├── vpc/
│       ├── security-groups/
│       ├── alb/
│       ├── ec2/
│       └── rds/
└── README.md
```

---

## Deploying This Yourself

### Prerequisites

- AWS CLI configured (`aws sts get-caller-identity`)
- Terraform v1.5.0+
- An EC2 key pair in your target region
- Your public IP (`curl -s ifconfig.me`)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/Soore-ai/book-review-app.git
cd book-review-app/terraform

# 2. Configure your variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars   # Fill in your region, IP, key pair, DB credentials

# 3. Generate a JWT secret
openssl rand -base64 32

# 4. Initialize and validate
terraform init
terraform validate

# 5. Review the plan (~33 resources)
terraform plan -out=tfplan

# 6. Apply (takes 10-15 min — RDS Multi-AZ provisioning is slow)
terraform apply tfplan

# 7. Wait 5-8 minutes for EC2 bootstrapping, then open the app
http://<public_alb_dns>
```

> ⚠️ **Cost Warning:** This infrastructure runs approximately $5–8/day on AWS free tier ineligible resources. Run `terraform destroy` when done.

### Key Outputs After Apply

```
public_alb_dns          → Your app URL
internal_alb_dns        → Internal backend endpoint
rds_endpoint            → Primary DB connection string
rds_read_replica_endpoint → Read replica endpoint
web_instance_public_ips → For SSH access
```

---

## What I Learned Building This

**Infrastructure design decisions:**
- Why the app tier has no public IPs — any instance in a private subnet reachable only through the internal ALB cannot be directly attacked from the internet, even if a security group rule were misconfigured
- Why the read replica matters — not just for reads, but as a warm standby that can be promoted faster than restoring from a snapshot

**Debugging real issues:**
- Targets stuck in "unhealthy" — traced to a bootstrap timing issue where the ALB health check fired before PM2 had started the Node.js process; solved by checking `/var/log/userdata.log` and adjusting the health check grace period
- CORS errors — the backend `ALLOWED_ORIGINS` env var had a trailing slash that didn't match the ALB DNS; fixed by stripping the slash

**Terraform specifics:**
- Resource dependency ordering matters — security groups must exist before EC2 instances; Terraform's implicit dependency graph handles most of this, but explicit `depends_on` was needed for the NAT Gateway before private subnet route tables

---

## Teardown

```bash
terraform destroy
# Type 'yes' when prompted
# Expected: 33 resources destroyed (~5-10 minutes)
```

---

## Related

- 📄 [Full Deployment Guide](./deployment-guide.md)
- 🌐 [Portfolio Writeup](https://sites.google.com/view/edeguaikhide/projects)
- ✍️ [Medium Blog Post](https://medium.com/@eguaikhidee/i-deployed-a-three-tier-app-on-aws-with-terraform-heres-what-actually-broke-be34184f22d7)
- 💼 [LinkedIn](https://linkedin.com/in/ed-eguaikhide)
