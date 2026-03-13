# Bucket *******************************************
resource "aws_s3_bucket" "wp_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "wp_bucket_public" {
  bucket = aws_s3_bucket.wp_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "wp_bucket_policy" {
  bucket = aws_s3_bucket.wp_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.wp_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.wp_bucket_public]
}

resource "aws_iam_role" "wp_role" {
  name = "wordpress-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wp_attach" {
  role       = aws_iam_role.wp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "wp_profile" {
  name = "wordpress-instance-profile"
  role = aws_iam_role.wp_role.name
}