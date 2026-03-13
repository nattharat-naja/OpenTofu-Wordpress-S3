output "app_public_ip" {
  value = module.app.elastic_ip
}

output "db_endpoint" {
  value = module.db.db_endpoint
}