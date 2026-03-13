resource "aws_db_parameter_group" "wordpress_pg" {
  name = "wordpress-mariadb-pg"
  family = "mariadb11.8"

  parameter {
    name = "require_secure_transport"
    value = "0"
  }

  tags = {
    Name = "wordpress-mariadb-pg"
  }
}

resource "aws_db_instance" "mariadb" {
  identifier              = "midterm-mariadb"
  engine                  = "mariadb"
  engine_version          = "11.8.5"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  parameter_group_name    = aws_db_parameter_group.wordpress_pg.name

  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.db_security_group_id]

  publicly_accessible     = false
  skip_final_snapshot     = true

  multi_az                = true

  tags = {
    Name = "midterm-mariaDB"
  }
}