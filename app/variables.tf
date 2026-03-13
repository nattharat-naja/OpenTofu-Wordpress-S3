variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_address" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "region" {
  type = string
}
