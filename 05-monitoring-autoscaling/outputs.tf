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

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "app_url" {
  description = "Public URL of the application (via ALB)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_via_alb_url" {
  description = "Backend URL via ALB path-based routing"
  value       = "http://${aws_lb.main.dns_name}/chat"
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

# ── Lista 6: nowe outputy ─────────────────────

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_backend_cpu" {
  description = "Name of the backend CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.backend_cpu_high.alarm_name
}

output "alarm_frontend_cpu" {
  description = "Name of the frontend CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.frontend_cpu_high.alarm_name
}

output "alarm_alb_unhealthy" {
  description = "Name of the ALB unhealthy-hosts CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name
}

output "backend_autoscaling_min" {
  description = "Minimum task count for backend auto scaling"
  value       = aws_appautoscaling_target.backend.min_capacity
}

output "backend_autoscaling_max" {
  description = "Maximum task count for backend auto scaling"
  value       = aws_appautoscaling_target.backend.max_capacity
}

output "frontend_autoscaling_min" {
  description = "Minimum task count for frontend auto scaling"
  value       = aws_appautoscaling_target.frontend.min_capacity
}

output "frontend_autoscaling_max" {
  description = "Maximum task count for frontend auto scaling"
  value       = aws_appautoscaling_target.frontend.max_capacity
}
