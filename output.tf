output "ec2_ip" {
  value = aws_instance.app.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subred1" {
  value = aws_subnet.subnet_1.cidr_block

}

output "subred2" {
  value = aws_subnet.subnet_2.cidr_block

}

