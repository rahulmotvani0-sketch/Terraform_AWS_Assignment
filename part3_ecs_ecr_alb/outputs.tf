output "ecr_backend_repository_url" {
  description = "Amazon ECR Repository URI for Flask Backend"
  value       = aws_ecr_repository.backend_repo.repository_url
}

output "ecr_frontend_repository_url" {
  description = "Amazon ECR Repository URI for Express Frontend"
  value       = aws_ecr_repository.frontend_repo.repository_url
}

output "alb_dns_name" {
  description = "Application Load Balancer Public DNS Name"
  value       = aws_lb.main.dns_name
}

output "alb_http_url" {
  description = "Direct URL to access the application via the Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the provisioned ECS cluster"
  value       = aws_ecs_cluster.main.name
}
