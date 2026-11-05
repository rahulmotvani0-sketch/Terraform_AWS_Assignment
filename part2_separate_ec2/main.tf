# ------------------------------------------------------------------------------
# Part 2: Decoupled Multi-Tier Deployment on Separate EC2 Instances
# Author: Rahul Motvani
# ------------------------------------------------------------------------------

# Fetch latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. Custom VPC & Networking Resources
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-fullstack-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "terraform-fullstack-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. Security Groups with Chained Ingress Rules
# Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-ec2-sg"
  description = "Security Group for Express Frontend Instance"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "SSH remote administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-ec2-sg"
  }
}

# Backend Security Group (Principle of Least Privilege)
resource "aws_security_group" "backend_sg" {
  name        = "backend-ec2-sg"
  description = "Security Group for Flask Backend Instance (Isolated)"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "SSH remote administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Strict ingress: Allow Port 5000 ONLY from Frontend Security Group"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-ec2-sg"
  }
}

# 3. Provision Backend EC2 Instance (Instance A)
resource "aws_instance" "backend_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  user_data              = file("${path.module}/backend_user_data.sh")

  tags = {
    Name = "EC2-Instance-A-Backend"
    Tier = "Backend-API"
  }
}

# 4. Provision Frontend EC2 Instance (Instance B)
# User-data dynamically injects the Backend Private IP!
resource "aws_instance" "frontend_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  user_data = templatefile("${path.module}/frontend_user_data.sh", {
    backend_private_ip = aws_instance.backend_node.private_ip
  })

  depends_on = [aws_instance.backend_node]

  tags = {
    Name = "EC2-Instance-B-Frontend"
    Tier = "Frontend-UI"
  }
}
