
# Spacelift worker pool module
module "my_workerpool" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v2.3.1"
  configuration = <<-EOT
    export SPACELIFT_TOKEN="${var.worker_pool_config}"
    export SPACELIFT_POOL_PRIVATE_KEY="${var.worker_pool_private_key}"
  EOT
  min_size          = 1
  max_size          = 5
  worker_pool_id    = var.worker_pool_id
  security_groups   = [aws_security_group.main.id]
  vpc_subnets       = [aws_subnet.private.id, aws_subnet.public.id]
  spacelift_api_key_secret = var.spacelift_api_key_secret
  spacelift_api_key_endpoint = var.spacelift_api_key_endpoint
  spacelift_api_key_id = var.spacelift_api_key_id
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
# VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "worker-pool-example-${random_string.suffix.id}"
  }
}
# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "public-subnet-${random_string.suffix.id}"
  }
}
# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "private-subnet-${random_string.suffix.id}"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet-gateway-${random_string.suffix.id}"
  }
}
# Route Table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-route-table-${random_string.suffix.id}"
  }
}
# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-${random_string.suffix.id}"
  }
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "nat-gateway-${random_string.suffix.id}"
  }
}
# Route Table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "private-route-table-${random_string.suffix.id}"
  }
}
# Associate the private route table with the private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# Security Group for the worker pool
resource "aws_security_group" "main" {
  name        = "worker-pool-example-${random_string.suffix.id}"
  description = "Worker pool security group, with unrestricted egress and restricted ingress"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
# Security Group Ingress Rules
resource "aws_security_group_rule" "ingress_rule_1" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["3.248.70.24/32"]
  description       = "Allow ingress from Spacelift IP 3.248.70.24"
  security_group_id = aws_security_group.main.id
}
resource "aws_security_group_rule" "ingress_rule_2" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["34.246.213.75/32"]
  description       = "Allow ingress from Spacelift IP 34.246.213.75"
  security_group_id = aws_security_group.main.id
}
resource "aws_security_group_rule" "ingress_rule_3" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["52.49.218.181/32"]
  description       = "Allow ingress from Spacelift IP 52.49.218.181"
  security_group_id = aws_security_group.main.id
}
