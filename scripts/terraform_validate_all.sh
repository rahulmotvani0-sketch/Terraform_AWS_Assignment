#!/usr/bin/env bash
# ==============================================================================
# Automated Linting, Formatting, and Validation for all Terraform Parts
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=================================================================="
echo "Terraform Code Quality Assurance & Validation Suite"
echo "=================================================================="

echo "[1/4] Checking code formatting across all modules..."
terraform fmt -check -recursive "${ROOT_DIR}" || {
    echo "[!] Unformatted files detected. Applying terraform fmt..."
    terraform fmt -recursive "${ROOT_DIR}"
}

echo "[2/4] Validating Part 1: Single EC2 Instance..."
(cd "${ROOT_DIR}/part1_single_ec2" && terraform init -backend=false >/dev/null && terraform validate)

echo "[3/4] Validating Part 2: Separate EC2 Instances..."
(cd "${ROOT_DIR}/part2_separate_ec2" && terraform init -backend=false >/dev/null && terraform validate)

echo "[4/4] Validating Part 3: ECS Fargate, ECR, VPC & ALB..."
(cd "${ROOT_DIR}/part3_ecs_ecr_alb" && terraform init -backend=false >/dev/null && terraform validate)

echo "=================================================================="
echo "All Terraform configurations are SYNTACTICALLY VALID & FORMATTED!"
echo "=================================================================="
