output "instance_id" {
  value = aws_instance.app_instance.id
}

output "elastic_ip" {
  value = aws_eip.app_eip.public_ip
}
