output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "frontend_public_ip" {
  description = "Elastic IP address of the frontend EC2 instance"
  value       = aws_eip.frontend.public_ip
}

output "frontend_private_ip" {
  description = "Private IP address of the frontend EC2 instance"
  value       = aws_instance.frontend.private_ip
}

output "backend_security_group_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend_sg.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend_sg.id
}

output "ssh_frontend" {
  description = "SSH command for the frontend instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_eip.frontend.public_ip}"
}

output "ssh_backend_via_bastion" {
  description = "SSH command for the backend instance via frontend as bastion"
  value       = "ssh -i ${var.key_name}.pem -J ec2-user@${aws_eip.frontend.public_ip} ec2-user@${aws_instance.backend.private_ip}"
}

output "frontend_url" {
  description = "URL aplikacji (frontend + proxy do backendu)"
  value       = "http://${aws_eip.frontend.public_ip}"
}

output "backend_via_proxy_url" {
  description = "URL backendu przez nginx proxy (nie bezposredni dostep)"
  value       = "http://${aws_eip.frontend.public_ip}/chat"
}

output "ssm_parameter_name" {
  description = "SSM Parameter Store name where backend IP is stored"
  value       = "/app/backend-ip"
}

output "setup_info" {
  description = "Setup information"
  value = {
    cors_origin              = var.frontend_public_origin != "" ? var.frontend_public_origin : "http://${aws_eip.frontend.public_ip}"
  }
}
