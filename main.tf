# Key pair
resource "aws_key_pair" "key_pair" {
  key_name = "fran-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTzsfnpLQhPf2x2xHG8sYoE11bgCGT4Pk4DcSBIJL4I aws"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Organization: Mikroways"
  }
}

# Subnets 
# 1 - 10.0.2.0/24
resource "aws_subnet" "subnet-1"{
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-1"
  }
}

# 2 - 10.0.2.0/24
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Organization: Mikroways"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Organization: Mikroways"
  }
}

# Asociar tablas
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.public_rtb.id
}

# Security Group para la EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Organization: Mikroways"
  }
}

# Instancia EC2
resource "aws_instance" "app" {
  ami                    = "ami-084a7d336e816906b"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "fran-key"

  # User data para instalar MySQL client
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Organization: Mikroways"
  }
}


output "ec2_ip" {
  value = aws_instance.app.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subred1" {
  value = aws_subnet.subnet-1.cidr_block

}

output "subred2" {
  value = aws_subnet.subnet-2.cidr_block

}

