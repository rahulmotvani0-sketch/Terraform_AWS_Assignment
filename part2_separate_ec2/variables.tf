variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the dedicated 2-tier VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet hosting Frontend and Backend"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size for both tiers (Free Tier eligible)"
  default     = "t2.micro"
}
