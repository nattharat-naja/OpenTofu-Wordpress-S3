output "db_address" {
  value = aws_db_instance.mariadb.address
}

output "db_endpoint" {
  value = aws_db_instance.mariadb.endpoint
}
