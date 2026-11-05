# DevOps Assignment 8: Terraform AWS Infrastructure as Code Documentation

**Author:** Rahul Motvani  
**Course:** DevOps Engineering  
**Assignment:** Terraform AWS Multi-Architecture Full-Stack Deployment (Assignment 8)  
**Date:** November 2026  
**GitHub Repository:** [https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment](https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment)  

---

## 1. Executive Summary & Provisioned Endpoints

This technical document details the design, provisioning, declarative configuration, and verification of a full-stack microservices application (Node.js/Express frontend and Python/Flask backend) deployed on **Amazon Web Services (AWS)** using **HashiCorp Terraform**.

The assignment encompasses three distinct architectural paradigms managed completely as code:

| Deployment Configuration | Architectural Paradigm | Public Access Endpoint / DNS | Internal Networking & Ports |
| :--- | :--- | :--- | :--- |
| **Part 1** | **Single EC2 Instance** (Monolithic Co-location) | `http://13.233.145.88:3000`<br>*(Nginx Proxy: `http://13.233.145.88`)* | Nginx Port 80 &rarr; Express (127.0.0.1:3000)<br>Flask Backend (127.0.0.1:5000) |
| **Part 2** | **Separate EC2 Instances** (Decoupled 2-Tier VPC) | **Frontend (Instance B):** `http://13.232.90.112:3000`<br>**Backend (Instance A):** `http://13.235.44.201:5000` | In-VPC Private IP: `10.0.1.45:5000`<br>Backend SG chained to Frontend SG |
| **Part 3** | **Containers via ECR, ECS (Fargate) & ALB** | **ALB Public DNS:**<br>`http://production-fullstack-alb-194028471.ap-south-1.elb.amazonaws.com` | AWS Fargate Pod (Multi-AZ VPC)<br>ECR: `891377014298.dkr.ecr.ap-south-1.amazonaws.com` |

---

## 2. Full Project Directory Layout

```
Terraform_Rahul/
├── backend/
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── frontend/
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   ├── public/
│   │   ├── css/style.css
│   │   └── js/main.js
│   ├── server.js
│   └── views/
│       ├── index.ejs
│       ├── result.ejs
│       └── submissions.ejs
├── part1_single_ec2/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── user_data.sh
│   └── variables.tf
├── part2_separate_ec2/
│   ├── backend_user_data.sh
│   ├── frontend_user_data.sh
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── part3_ecs_ecr_alb/
│   ├── alb.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── vpc.tf
├── scripts/
│   ├── aws_cost_cleanup.sh
│   ├── ecr_build_and_push.sh
│   └── terraform_validate_all.sh
├── backend.tf.example
├── DOCUMENTATION.md
├── README.md
├── Assignment_8_Terraform_Report.docx
└── Assignment_8_Terraform_Report.pdf
```

---

## 3. Part 1: Single EC2 Instance Full-Stack Deployment

### 3.1 Architecture & Components
- **Terraform Resource:** `aws_instance.fullstack_node` provisioned in the default VPC.
- **AMI Discovery:** Dynamic data source `data.aws_ami.ubuntu` fetching the latest official Canonical Ubuntu 24.04 LTS image.
- **Security Group:** `aws_security_group.fullstack_sg` allowing ports 22 (SSH), 80 (HTTP Nginx), 3000 (Express), and 5000 (Flask).
- **Bootstrap Automation:** `user_data.sh` installs Node.js 20 LTS, Python 3 venv, clones application code, installs dependencies, and registers `systemd` units for both microservices with auto-restart policies.

### 3.2 Terraform Commands & Workflow
```bash
cd part1_single_ec2
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

---

## 4. Part 2: Separate EC2 Instances (Decoupled 2-Tier VPC)

### 4.1 Architecture & Least-Privilege Security Chaining
- **Networking:** Dedicated VPC (`10.0.0.0/16`), public subnet (`10.0.1.0/24`), Internet Gateway, and Route Table associations.
- **Security Group Ingress Chaining:**
  - `aws_security_group.frontend_sg`: Exposes ports 80, 3000, and 22 to `0.0.0.0/0`.
  - `aws_security_group.backend_sg`: **Restricts port 5000 ingress strictly to `aws_security_group.frontend_sg.id`**. Direct internet connections to port 5000 are rejected by the AWS packet filter.
- **Dynamic Parameter Injection:**
  ```hcl
  user_data = templatefile("${path.module}/frontend_user_data.sh", {
    backend_private_ip = aws_instance.backend_node.private_ip
  })
  ```
  The Frontend user data dynamically receives the Backend instance's private IP (`10.0.1.45`), injecting `BACKEND_URL=http://10.0.1.45:5000` into the Express service definition.

---

## 5. Part 3: Docker Containers via ECR, ECS Fargate & ALB

### 5.1 Architecture Overview
- **Amazon ECR:** Two repositories (`aws-devops-flask-backend` and `aws-devops-express-frontend`) with `scan_on_push = true`.
- **Custom Multi-AZ VPC:** Spans 2 Availability Zones (`ap-south-1a`, `ap-south-1b`) with 2 public subnets (`10.0.1.0/24`, `10.0.2.0/24`) required for ALB high availability.
- **Application Load Balancer (ALB):** Public internet-facing ALB listening on HTTP port 80. Routes traffic based on URL paths:
  - Default route (`/*`): Forwards to `aws_lb_target_group.frontend_tg` on port 3000.
  - Path rule (`/api/*`): Forwards to `aws_lb_target_group.backend_tg` on port 5000.
- **Amazon ECS & AWS Fargate:** Serverless container orchestration (`launch_type = "FARGATE"`). Dual-container task definition shares `awsvpc` network stack, allowing frontend to backend communication via `http://localhost:5000`.

---

## 6. Remote State Management & S3 Backend

In enterprise teams, local state files (`terraform.tfstate`) risk state drift and race conditions. A production-grade S3 backend is documented in `backend.tf.example`:
```hcl
terraform {
  backend "s3" {
    bucket         = "rahul-terraform-state-devops"
    key            = "devops/assignment8/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
```
- **S3 Bucket:** Stores state files with versioning enabled and AES-256 server-side encryption.
- **DynamoDB Table:** Provides distributed locking (`LockID`) preventing concurrent applies.

---

## 7. Cost Avoidance & Teardown Protocol

To maintain zero unnecessary charges against the AWS Free Tier, the project includes an automated teardown utility:
```bash
# Destroy a specific deployment part:
./scripts/aws_cost_cleanup.sh part1
./scripts/aws_cost_cleanup.sh part2
./scripts/aws_cost_cleanup.sh part3

# Destroy all deployed infrastructure:
./scripts/aws_cost_cleanup.sh all
```
