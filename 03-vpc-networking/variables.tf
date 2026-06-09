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
  default     = "lista4-app"
  description = "Project name for tagging resources"
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
  description = "CIDR for public subnet in AZ-a (used by ALB)"
}

variable "public_subnet_cidr_b" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR for public subnet in AZ-b (used by ALB)"
}

variable "private_subnet_cidr_a" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR for private subnet in AZ-a (used by ECS tasks)"
}

variable "private_subnet_cidr_b" {
  type        = string
  default     = "10.0.4.0/24"
  description = "CIDR for private subnet in AZ-b (used by ECS tasks)"
}

variable "backend_port" {
  type        = number
  default     = 8080
  description = "Port on which the backend (Spring Boot) container listens"
}

variable "frontend_container_port" {
  type        = number
  default     = 80
  description = "Port on which the frontend (nginx/React) container listens"
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
  default     = "nashsg1/backend:latest"
  description = "Docker image for the Spring Boot backend"
}

variable "frontend_docker_image" {
  type        = string
  default     = "nashsg1/frontend:latest"
  description = "Docker image for the React frontend"
}
