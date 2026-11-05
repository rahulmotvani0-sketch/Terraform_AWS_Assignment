#!/usr/bin/env bash
# ==============================================================================
# Docker Build & Push to Terraform-provisioned Amazon ECR Repositories
# ==============================================================================
set -euo pipefail

AWS_REGION="${1:-ap-south-1}"
AWS_ACCOUNT_ID="${2:-891377014298}"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

BACKEND_REPO="${REGISTRY}/aws-devops-flask-backend"
FRONTEND_REPO="${REGISTRY}/aws-devops-express-frontend"

echo "=================================================================="
echo "Authenticating Docker with Amazon ECR: ${REGISTRY}"
echo "=================================================================="
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${REGISTRY}" || true

echo "Building Docker container images..."
docker build -t aws-devops-flask-backend:latest ../backend
docker build -t aws-devops-express-frontend:latest ../frontend

echo "Tagging container images for ECR..."
docker tag aws-devops-flask-backend:latest "${BACKEND_REPO}:latest"
docker tag aws-devops-express-frontend:latest "${FRONTEND_REPO}:latest"

echo "Pushing images to Amazon ECR..."
docker push "${BACKEND_REPO}:latest" || true
docker push "${FRONTEND_REPO}:latest" || true

echo "Images ready for ECS Fargate deployment!"
