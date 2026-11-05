#!/usr/bin/env bash
# ==============================================================================
# AWS Cost Optimization and Infrastructure Teardown Utility
# ==============================================================================
set -euo pipefail

TARGET_PART="${1:-all}"

echo "=================================================================="
echo "AWS Resource Teardown & Cost Avoidance Utility"
echo "=================================================================="

destroy_part() {
    local dir="$1"
    local name="$2"
    echo "Destroying ${name} in ${dir}..."
    if [ -d "${dir}/.terraform" ]; then
        (cd "${dir}" && terraform destroy -auto-approve || true)
    else
        echo "No active terraform state found in ${dir}. Skipping."
    fi
}

case "${TARGET_PART}" in
    part1)
        destroy_part "../part1_single_ec2" "Part 1 (Single EC2)"
        ;;
    part2)
        destroy_part "../part2_separate_ec2" "Part 2 (Separate EC2)"
        ;;
    part3)
        destroy_part "../part3_ecs_ecr_alb" "Part 3 (ECS Fargate + ALB)"
        ;;
    all)
        destroy_part "../part1_single_ec2" "Part 1 (Single EC2)"
        destroy_part "../part2_separate_ec2" "Part 2 (Separate EC2)"
        destroy_part "../part3_ecs_ecr_alb" "Part 3 (ECS Fargate + ALB)"
        ;;
    *)
        echo "Usage: $0 [part1|part2|part3|all]"
        exit 1
        ;;
esac

echo "Cost avoidance cleanup completed."
