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
  default     = "lista5-app"
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
  description = "CIDR for public subnet in AZ-a (ALB)"
}

variable "public_subnet_cidr_b" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR for public subnet in AZ-b (ALB)"
}

variable "private_subnet_cidr_a" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR for private subnet in AZ-a (ECS tasks)"
}

variable "private_subnet_cidr_b" {
  type        = string
  default     = "10.0.4.0/24"
  description = "CIDR for private subnet in AZ-b (ECS tasks)"
}

variable "db_subnet_cidr_a" {
  type        = string
  default     = "10.0.5.0/24"
  description = "CIDR for database subnet in AZ-a (RDS, no internet route)"
}

variable "db_subnet_cidr_b" {
  type        = string
  default     = "10.0.6.0/24"
  description = "CIDR for database subnet in AZ-b (RDS, no internet route)"
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
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
}

variable "task_memory" {
  type        = number
  default     = 1024
  description = "Fargate task memory in MiB"
}

variable "desired_count" {
  type        = number
  default     = 2
  description = "Number of ECS task instances per service"
}

variable "backend_docker_image" {
  type        = string
  default     = "nashsg1/backend:lista5"
  description = "Docker image for the Spring Boot backend (must include S3 + PostgreSQL support)"
}

variable "frontend_docker_image" {
  type        = string
  default     = "nashsg1/frontend:lista5"
  description = "Docker image for the React frontend"
}

# ── RDS ──────────────────────────────────────

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
  default     = "16.6"
  description = "PostgreSQL engine version"
}
