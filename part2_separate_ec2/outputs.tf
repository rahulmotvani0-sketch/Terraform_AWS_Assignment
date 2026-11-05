output "backend_instance_id" {
  description = "EC2 Instance A (Backend) ID"
  value       = aws_instance.backend_node.id
}

output "backend_private_ip" {
  description = "Private IP of Backend instance (used for internal in-VPC communication)"
  value       = aws_instance.backend_node.private_ip
}

output "backend_public_ip" {
  description = "Public IP of Backend instance"
  value       = aws_instance.backend_node.public_ip
}

output "frontend_instance_id" {
  description = "EC2 Instance B (Frontend) ID"
  value       = aws_instance.frontend_node.id
}

output "frontend_public_ip" {
  description = "Public IP of Frontend instance"
  value       = aws_instance.frontend_node.public_ip
}

output "frontend_url" {
  description = "Direct Node.js web access URL"
  value       = "http://${aws_instance.frontend_node.public_ip}:3000"
}

output "frontend_nginx_url" {
  description = "HTTP Port 80 access via Nginx reverse proxy"
  value       = "http://${aws_instance.frontend_node.public_ip}"
}
