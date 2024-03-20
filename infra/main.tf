terraform {
    # backend "s3"{}
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "3.45.0"
        }
    }   
}

provider "aws" {
  region = var.region # Update to your preferred AWS region
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs_vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "ecs_subnet" {
  count                   = 2 # Create 2 subnets
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  map_public_ip_on_launch = true # Enables public IP assignment
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "ecs_subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "ecs_igw"
  }
}

resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Name = "ecs_route_table"
  }
}

resource "aws_security_group" "liferay_sg" {
  name        = "liferay-sg"
  description = "Security group for Liferay ECS service"
  vpc_id      = aws_vpc.ecs_vpc.id

  # Allow inbound HTTP traffic on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "liferay-ecs-sg"
  }
}

resource "aws_route_table_association" "ecs_rta" {
  count          = length(aws_subnet.ecs_subnet)
  subnet_id      = aws_subnet.ecs_subnet[count.index].id
  route_table_id = aws_route_table.ecs_route_table.id
}

