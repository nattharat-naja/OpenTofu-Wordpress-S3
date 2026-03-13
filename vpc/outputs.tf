output "vpc_id" {
  value = aws_vpc.midterm_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_A_id" {
  value = aws_subnet.private_subnet_A.id
}

output "private_subnet_B_id" {
  value = aws_subnet.private_subnet_B.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}
