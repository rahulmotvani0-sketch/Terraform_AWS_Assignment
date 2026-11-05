output "instance_id" {
  description = "Unique ID of provisioned EC2 instance"
  value       = aws_instance.fullstack_node.id
}

output "instance_public_ip" {
  description = "Public IPv4 address assigned to the EC2 host"
  value       = aws_instance.fullstack_node.public_ip
}

output "instance_public_dns" {
  description = "Public DNS hostname of the EC2 instance"
  value       = aws_instance.fullstack_node.public_dns
}

output "frontend_url" {
  description = "Direct URL to access the Express frontend"
  value       = "http://${aws_instance.fullstack_node.public_ip}:3000"
}

output "nginx_proxy_url" {
  description = "URL to access the frontend via Nginx reverse proxy (Port 80)"
  value       = "http://${aws_instance.fullstack_node.public_ip}"
}

output "backend_health_url" {
  description = "Direct URL to check Flask backend health"
  value       = "http://${aws_instance.fullstack_node.public_ip}:5000/health"
}
