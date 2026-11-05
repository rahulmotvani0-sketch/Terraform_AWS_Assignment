# ------------------------------------------------------------------------------
# Part 1: Single EC2 Instance Full-Stack Deployment (Flask + Express)
# Author: Rahul Motvani
# ------------------------------------------------------------------------------

# Fetch latest official Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC lookup
data "aws_vpc" "default" {
  default = true
}

# Security Group for Single EC2 Full-Stack Host
resource "aws_security_group" "fullstack_sg" {
  name        = "${var.project_name}-sg"
  description = "Security Group allowing inbound HTTP, Express (3000), Flask (5000), and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH remote administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Public HTTP web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Direct Node.js Express frontend access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Direct Python Flask backend API access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound internet traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance Resource
resource "aws_instance" "fullstack_node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.fullstack_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name     = "${var.project_name}-instance"
    Tier     = "Fullstack-Monolith"
    AutoStop = "True"
  }
}
