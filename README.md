# Terraform Multi-Architecture AWS Full-Stack Deployment

[![Terraform](https://img.shields.io/badge/Terraform-v1.10.5-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud%20Provider-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)](https://www.docker.com)
[![Node.js](https://img.shields.io/badge/Node.js-v20%20LTS-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Python Flask](https://img.shields.io/badge/Python-Flask%203.1-3776AB?logo=flask&logoColor=white)](https://flask.palletsprojects.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📌 Project Overview
This repository contains the complete implementation for **DevOps Assignment 8: Terraform** by **Rahul Motvani**.

The project provisions, configures, and validates three distinct cloud architectures on Amazon Web Services using HashiCorp Terraform:
1. **Part 1 (Single EC2):** Full-stack co-location with automated cloud-init and Nginx reverse proxy.
2. **Part 2 (Separate EC2s):** Decoupled 2-tier architecture with dedicated VPC, subnets, and least-privilege security group chaining.
3. **Part 3 (Containers with ECR, ECS & ALB):** Serverless container orchestration on AWS Fargate fronted by an Application Load Balancer with path-based routing.

---

## 🌐 Provisioned Endpoints
- **Part 1 (Single EC2):** `http://13.233.145.88:3000` *(Nginx Proxy: `http://13.233.145.88`)*
- **Part 2 (Separate EC2s):**
  - Frontend: `http://13.232.90.112:3000`
  - Backend: `http://13.235.44.201:5000` *(Private IP: `10.0.1.45:5000`)*
- **Part 3 (ECS Fargate + ALB):** `http://production-fullstack-alb-194028471.ap-south-1.elb.amazonaws.com`

---

## 🚀 Quick Start Guide

### 1. Validate All Terraform Code
```bash
./scripts/terraform_validate_all.sh
```

### 2. Deploy Part 1 (Single EC2)
```bash
cd part1_single_ec2
terraform init
terraform plan
terraform apply
```

### 3. Deploy Part 2 (Separate EC2 Instances)
```bash
cd part2_separate_ec2
terraform init
terraform plan
terraform apply
```

### 4. Deploy Part 3 (ECS Fargate + ECR + ALB)
```bash
cd part3_ecs_ecr_alb
terraform init
terraform plan
terraform apply
```

### 5. Cost Avoidance Teardown
```bash
./scripts/aws_cost_cleanup.sh all
```

---

## 📂 Quick Links
- [Detailed Technical Documentation](DOCUMENTATION.md)
- [Official Assignment Report (PDF)](Assignment_8_Terraform_Report.pdf)
- [Official Assignment Report (Word DOCX)](Assignment_8_Terraform_Report.docx)
- [Remote S3 State Configuration](backend.tf.example)

---

## 👨‍💻 Author
- **Student Name:** Rahul Motvani
- **GitHub:** [@rahulmotvani0-sketch](https://github.com/rahulmotvani0-sketch)
- **Repository:** [Terraform_AWS_Assignment](https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment)
