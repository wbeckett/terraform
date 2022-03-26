locals {
  vpc_name        = "vpc-${terraform.workspace}"
  workspace_title = title("${terraform.workspace}")
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Define our VPC
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

# Define the public subnet - A
resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.workspace_title} - Public Subnet - A"
  }
}

# Define the public subnet - B
resource "aws_subnet" "public-subnet-b" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.workspace_title} - Pubic Subnet - B"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.workspace_title} - VPC IGW"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Define the route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.workspace_title} - Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public.id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${local.workspace_title}-sg"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow internal traffic"
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["88.99.82.251/32"]
    description = "Allow internal traffic"
  }


  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow out all traffic"
  }

  tags = {
    Environment = "${local.workspace_title} SG"
  }
}

# AL Security Group of VPC
resource "aws_security_group" "alb" {
  name        = "${local.workspace_title}-alb-sg"
  description = "Allow in all HTTP/HTTPS traffic to a ALB"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP to the ALB"
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS to the ALB"
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow out all traffic"
  }

  tags = {
    Environment = "${local.workspace_title} ALB SG"
  }
}

