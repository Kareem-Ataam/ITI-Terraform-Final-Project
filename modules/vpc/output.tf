output "vpc_id" {
  value = aws_vpc.my_app_vpc.id
}
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}
output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}
output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}
output "public_instance_sg_id" {
  value = aws_security_group.public_instance_sg.id
}
output "private_instance_sg_id" {
  value = aws_security_group.private_instance_sg.id
}
