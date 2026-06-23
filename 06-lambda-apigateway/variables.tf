variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for all resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "project_name" {
  type        = string
  default     = "lista7-app"
  description = "Project name used for naming and tagging resources"
}

variable "availability_zone_a" {
  type        = string
  default     = "us-east-1a"
  description = "First availability zone"
}

variable "availability_zone_b" {
  type        = string
  default     = "us-east-1b"
  description = "Second availability zone"
}

variable "public_subnet_cidr_a" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR for public subnet in AZ-a"
}

variable "public_subnet_cidr_b" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR for public subnet in AZ-b"
}

variable "private_subnet_cidr_a" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR for private subnet in AZ-a (ECS tasks, Lambda)"
}

variable "private_subnet_cidr_b" {
  type        = string
  default     = "10.0.4.0/24"
  description = "CIDR for private subnet in AZ-b (ECS tasks, Lambda)"
}

variable "db_subnet_cidr_a" {
  type        = string
  default     = "10.0.5.0/24"
  description = "CIDR for database subnet in AZ-a"
}

variable "db_subnet_cidr_b" {
  type        = string
  default     = "10.0.6.0/24"
  description = "CIDR for database subnet in AZ-b"
}

variable "backend_port" {
  type        = number
  default     = 8080
  description = "Port on which the backend container listens"
}

variable "frontend_container_port" {
  type        = number
  default     = 80
  description = "Port on which the frontend container listens"
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "Fargate task CPU units"
}

variable "task_memory" {
  type        = number
  default     = 1024
  description = "Fargate task memory in MiB"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Initial number of ECS task instances per service"
}

variable "backend_docker_image" {
  type        = string
  default     = "nashsg1/backend:lista5"
  description = "Docker image for the Spring Boot backend"
}

variable "frontend_docker_image" {
  type        = string
  default     = "nashsg1/frontend:lista5"
  description = "Docker image for the React frontend"
}

variable "db_name" {
  type        = string
  default     = "chatdb"
  description = "Name of the PostgreSQL database"
}

variable "db_username" {
  type        = string
  default     = "chatadmin"
  description = "Master username for the RDS instance"
}

variable "db_password" {
  type        = string
  default     = "chatpassword123!"
  sensitive   = true
  description = "Master password for the RDS instance"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_engine_version" {
  type        = string
  default     = "16.9"
  description = "PostgreSQL engine version"
}

variable "alarm_email" {
  type        = string
  default     = "280655@student.pwr.edu.pl"
  description = "das"
}

variable "cpu_high_threshold" {
  type        = number
  default     = 70
  description = "CPU utilisation % that triggers the high-CPU CloudWatch alarm"
}

variable "cpu_scale_target" {
  type        = number
  default     = 50
  description = "Target CPU utilisation % for ECS target-tracking auto scaling"
}

variable "min_task_count" {
  type        = number
  default     = 1
  description = "Minimum number of ECS tasks for auto scaling"
}

variable "max_task_count" {
  type        = number
  default     = 4
  description = "Maximum number of ECS tasks for auto scaling"
}

variable "lambda_notification_email" {
  type        = string
  default     = "280655@student.pwr.edu.pl"
  description = "dsadas"
}
