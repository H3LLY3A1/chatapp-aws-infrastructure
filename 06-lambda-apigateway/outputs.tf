output "app_url" {
  description = "Public URL of the application (via ALB)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "backend_via_alb_url" {
  description = "Backend URL via ALB path-based routing"
  value       = "http://${aws_lb.main.dns_name}/chat"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.main.address
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for chat images"
  value       = aws_s3_bucket.images.bucket
}

# ── Lista 6 ───────────────────────────────────────────────────────────────────

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic (CloudWatch alarms)"
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

# ── Lista 7 ───────────────────────────────────────────────────────────────────

output "api_gateway_url" {
  description = "API Gateway endpoint – POST /messages"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/messages"
}

output "lambda_function_name" {
  description = "Name of the Lambda message processor function"
  value       = aws_lambda_function.message_processor.function_name
}

output "number_alerts_sns_arn" {
  description = "ARN of the SNS topic for number-detection notifications"
  value       = aws_sns_topic.number_alerts.arn
}
