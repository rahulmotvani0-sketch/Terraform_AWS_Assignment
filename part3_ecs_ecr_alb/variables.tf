variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Environment identifier"
  default     = "production"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the custom VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs across multiple availability zones for ALB"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ecs_task_cpu" {
  type        = string
  description = "Fargate Task vCPU allocation"
  default     = "512"
}

variable "ecs_task_memory" {
  type        = string
  description = "Fargate Task Memory allocation in MiB"
  default     = "1024"
}
