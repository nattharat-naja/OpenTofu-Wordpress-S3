# Root main.tf - orchestrates all modules

module "vpc" {
  source = "./vpc"
  
  availability_zone_A = var.availability_zone_A
  availability_zone_B = var.availability_zone_B
}

module "security_group" {
  source = "./security_group"
  
  vpc_id = module.vpc.vpc_id
}

module "bucket" {
  source = "./bucket"
  
  bucket_name = var.bucket_name
}

module "db" {
  source = "./db"
  
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id = module.security_group.db_sg_id
}

module "app" {
  source = "./app"
  
  ami_id                   = var.ami_id
  instance_type            = var.instance_type
  public_subnet_id         = module.vpc.public_subnet_id
  app_security_group_id    = module.security_group.app_sg_id
  instance_profile_name    = module.bucket.instance_profile_name
  db_name                  = var.db_name
  db_username              = var.db_username
  db_password              = var.db_password
  db_address               = module.db.db_address
  bucket_name              = var.bucket_name
  region                   = var.region

  depends_on = [module.bucket, module.db]
}
