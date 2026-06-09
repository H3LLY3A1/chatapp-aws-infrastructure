variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for all resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "AWS VPC CIDR block"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "project_name" {
  type        = string
  default     = "lista3-app"
  description = "Project name for tagging resources"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for the private subnet"
}

variable "availability_zone_a" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "Availability zone for the private subnet"
  type        = string
  default     = "us-east-1b"
}

variable "backend_port" {
  type        = number
  default     = 8080
  description = "Port on which the backend (Spring Boot) application runs"
}

variable "http_port" {
  type        = number
  default     = 80
  description = "Port for HTTP access to frontend application"
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "Port for SSH access to EC2 instances"
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDRs for SSH access"
}

variable "https_port" {
  type        = number
  default     = 443
  description = "Port for HTTPS access to frontend application"
}

variable "ephemeral_port_start" {
  type        = number
  default     = 1024
  description = "Start of the ephemeral port range"
}

variable "ephemeral_port_end" {
  type        = number
  default     = 65535
  description = "End of the ephemeral port range"
}

variable "egress_port" {
  type        = number
  default     = 0
  description = "Port for egress traffic (0 means all ports)"
}

variable "icmp_port" {
  type        = number
  default     = 0
  description = "Port for ICMP traffic (0 means all ICMP types)"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "MyKey"
}

variable "backend_docker_image" {
  description = "Docker image dla Spring Boot backendu)"
  type        = string
  default     = "nashsg1/backend:latest"
}

variable "frontend_docker_image" {
  description = "Docker image dla frontendu React"
  type        = string
  default     = "nashsg1/frontend:latest"
}

variable "backend_upstream_host" {
  description = "Backend host/IP override (optional). If empty, nginx proxy uses backend private IP from Terraform resource."
  type        = string
  default     = ""
}

variable "frontend_public_origin" {
  description = "Public frontend origin used for backend CORS"
  type        = string
  default     = ""
}


