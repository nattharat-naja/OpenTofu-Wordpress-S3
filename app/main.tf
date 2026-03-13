# Elastic *******************************************
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_instance.id
  domain   = "vpc"

  tags = {
    Name = "app-elastic-ip"
  }
}

# Instance *******************************************
resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.app_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name
  key_name                    = "IAC"

  user_data = <<-EOF
#!/bin/bash
set -e

# Update system
apt update -y

# Install Apache + PHP + MySQL client
apt install -y apache2 php8.3 libapache2-mod-php8.3 php8.3-mysql php8.3-curl php8.3-gd php8.3-mbstring php8.3-xml mariadb-client wget unzip

# Start Apache
systemctl start apache2
systemctl enable apache2

# Download WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Set permissions
chown -R www-data:www-data wordpress
chmod -R 755 wordpress

# Configure WordPress
cd wordpress
cp wp-config-sample.php wp-config.php

# Configure WordPress database settings
sed -i "s/database_name_here/${var.db_name}/" wp-config.php
sed -i "s/username_here/${var.db_username}/" wp-config.php
sed -i "s/password_here/${var.db_password}/" wp-config.php
sed -i "s/localhost/${var.db_address}/" wp-config.php

# Allow WordPress to use current URL dynamically
sed -i "/<?php/a if (isset(\$_SERVER['HTTP_HOST'])) { define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST']); define('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST']); }" wp-config.php

# Insert S3 configuration before "That's all, stop editing!"
sed -i "/That's all, stop editing/i \\
// S3 Configuration\\
define('AS3CF_SETTINGS', serialize(array(\\
    'provider' => 'aws',\\
    'use-server-roles' => true,\\
    'bucket' => '${var.bucket_name}',\\
    'region' => '${var.region}',\\
    'object-prefix' => 'uploads/',\\
    'copy-to-s3' => true,\\
    'serve-from-s3' => true,\\
)));\\
" wp-config.php

# Install WordPress S3 plugin
cd /var/www/html/wordpress/wp-content/plugins
wget https://downloads.wordpress.org/plugin/amazon-s3-and-cloudfront.latest-stable.zip
unzip amazon-s3-and-cloudfront.latest-stable.zip
rm amazon-s3-and-cloudfront.latest-stable.zip
chown -R www-data:www-data amazon-s3-and-cloudfront

# Change document root
a2enmod rewrite

cat > /etc/apache2/sites-available/000-default.conf <<'APACHEEOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
APACHEEOF

# Restart Apache
systemctl restart apache2

# Add SSH key
mkdir -p /home/ubuntu/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress" >> /home/ubuntu/.ssh/authorized_keys
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

EOF

  tags = {
    Name = "app"
  }
}
