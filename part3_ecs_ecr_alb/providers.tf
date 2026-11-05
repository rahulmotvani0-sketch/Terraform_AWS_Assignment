terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "DevOps-Assignment-8-Terraform"
      Author    = "Rahul Motvani"
      ManagedBy = "Terraform"
      Part      = "Part-3-ECS-ECR-VPC-ALB"
    }
  }
}
