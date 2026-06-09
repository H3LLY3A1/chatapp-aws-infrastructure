output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "ID of public subnet A (ALB)"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "ID of public subnet B (ALB)"
  value       = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  description = "ID of private subnet A (ECS tasks)"
  value       = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "ID of private subnet B (ECS tasks)"
  value       = aws_subnet.private_b.id
}

output "db_subnet_a_id" {
  description = "ID of database subnet A"
  value       = aws_subnet.db_a.id
}

output "db_subnet_b_id" {
  description = "ID of database subnet B"
  value       = aws_subnet.db_b.id
}

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_sg.id
}

output "db_sg_id" {
  description = "ID of the RDS security group (only allows inbound from ECS SG)"
  value       = aws_security_group.db_sg.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "app_url" {
  description = "Public URL of the application (via ALB)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_via_alb_url" {
  description = "Backend URL via ALB path-based routing"
  value       = "http://${aws_lb.main.dns_name}/chat"
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "s3_bucket_name" {
  description = "Name of the private S3 bucket for chat images"
  value       = aws_s3_bucket.images.bucket
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (host only, without port)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.main.port
}

output "rds_db_name" {
  description = "Name of the PostgreSQL database"
  value       = aws_db_instance.main.db_name
}
