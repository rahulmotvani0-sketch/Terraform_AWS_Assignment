# ------------------------------------------------------------------------------
# Amazon Elastic Container Registry (ECR) Repositories
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "backend_repo" {
  name                 = "aws-devops-flask-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "flask-backend-ecr"
  }
}

resource "aws_ecr_repository" "frontend_repo" {
  name                 = "aws-devops-express-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "express-frontend-ecr"
  }
}
