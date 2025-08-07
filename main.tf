# Key pair
resource "aws_key_pair" "key_pair" {
  key_name = "fran-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTzsfnpLQhPf2x2xHG8sYoE11bgCGT4Pk4DcSBIJL4I aws"
}

# Instancia EC2
resource "aws_instance" "app" {
  ami                    = "ami-084a7d336e816906b"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_1.id
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
