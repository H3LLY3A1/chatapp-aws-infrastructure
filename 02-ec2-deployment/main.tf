terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#AMI
data "aws_ami" "amazon_linux" {  
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#USER DATA
locals {
  backend_upstream_host = var.backend_upstream_host != "" ? var.backend_upstream_host : aws_instance.backend.private_ip

  backend_user_data = <<-EOF
    #!/bin/bash
    set -e

    for i in {1..20}; do yum makecache -y && break || sleep 15; done
    yum update -y || true
    amazon-linux-extras install docker -y || yum install -y docker || dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    docker run -d \
      --name backend \
      --restart unless-stopped \
      -p ${var.backend_port}:${var.backend_port} \
      -e "SERVER_PORT=${var.backend_port}" \
      -e "cors.allowed.origins=${var.frontend_public_origin != "" ? var.frontend_public_origin : "*"}" \
      ${var.backend_docker_image}
  EOF

  frontend_user_data = <<-EOF
    #!/bin/bash
    set -e

    for i in {1..20}; do yum makecache -y && break || sleep 15; done
    yum update -y || true
    amazon-linux-extras install docker nginx1 -y || yum install -y docker nginx || dnf install -y docker nginx
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    docker run -d \
      --name frontend-app \
      --restart unless-stopped \
      -p 3000:80 \
      ${var.frontend_docker_image}

    cat > /etc/nginx/conf.d/app.conf <<'NGINX'
server {
    listen 80;
    # listen 443 ssl;

    location / {
        proxy_pass         http://127.0.0.1:3000;
        proxy_http_version 1.1;
      proxy_set_header   Host              $host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    }

    location /chat {
      proxy_pass         http://${local.backend_upstream_host}:${var.backend_port}/chat;

      proxy_http_version 1.1;
      proxy_set_header   Host              $host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_connect_timeout 10s;
      proxy_read_timeout    60s;
    }

    location /chat/ {
      proxy_pass         http://${local.backend_upstream_host}:${var.backend_port}/chat/;

      proxy_http_version 1.1;
      proxy_set_header   Host              $host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_connect_timeout 10s;
      proxy_read_timeout    60s;
    }

}
NGINX

    rm -f /etc/nginx/conf.d/default.conf
    systemctl start nginx
    systemctl enable nginx
  EOF
}

#SIEĆ
resource "aws_vpc" "main" { #virtual private cloud
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name        = "${var.project_name}-nat-gateway"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

#SECURITY GROUPS
resource "aws_security_group" "frontend_sg" {
  name        = "${var.project_name}-frontend-sg"
  description = "Security group for frontend EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  ingress {
    description = "HTTP"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-frontend-sg"
    Project     = var.project_name
    Environment = var.environment
    Role        = "frontend"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "${var.project_name}-backend-sg"
  description = "Security group for backend EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC only"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "Spring Boot from frontend SG only"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-backend-sg"
    Project     = var.project_name
    Environment = var.environment
    Role        = "backend"
  }
}

#NETWORK ACLs
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.ssh_port
    to_port    = var.ssh_port
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.http_port
    to_port    = var.http_port
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.https_port
    to_port    = var.https_port
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.backend_port
    to_port    = var.backend_port
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.ephemeral_port_start
    to_port    = var.ephemeral_port_end
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    from_port  = var.egress_port
    to_port    = var.egress_port
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name        = "${var.project_name}-public-nacl"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.ssh_port
    to_port    = var.ssh_port
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 110
    protocol   = "icmp"
    action     = "allow"
    from_port  = var.icmp_port
    to_port    = var.icmp_port
    cidr_block = var.vpc_cidr
  }

  ingress {
    rule_no    = 115
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.backend_port
    to_port    = var.backend_port
    cidr_block = var.public_subnet_cidr
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    from_port  = var.ephemeral_port_start
    to_port    = var.ephemeral_port_end
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    from_port  = var.egress_port
    to_port    = var.egress_port
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name        = "${var.project_name}-private-nacl"
    Project     = var.project_name
    Environment = var.environment
  }
}

#EC2 INSTANCES
resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = base64encode(local.frontend_user_data)

  tags = {
    Name        = "${var.project_name}-frontend"
    Project     = var.project_name
    Environment = var.environment
    Role        = "frontend"
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "frontend" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-frontend-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_eip_association" "frontend" {
  instance_id   = aws_instance.frontend.id
  allocation_id = aws_eip.frontend.id
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]
  associate_public_ip_address = false
  user_data_replace_on_change = true

  user_data = base64encode(local.backend_user_data)

  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table_association.private
  ]

  tags = {
    Name        = "${var.project_name}-backend"
    Project     = var.project_name
    Environment = var.environment
    Role        = "backend"
    ManagedBy   = "terraform"
  }
}
