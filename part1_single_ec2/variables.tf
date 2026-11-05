variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size (Free Tier eligible)"
  default     = "t2.micro"
}

variable "project_name" {
  type        = string
  description = "Project identifier tag"
  default     = "single-ec2-fullstack"
}

variable "admin_cidr" {
  type        = string
  description = "CIDR block permitted for administrative SSH access"
  default     = "0.0.0.0/0"
}
