output "bucket_arn" {
  value = aws_s3_bucket.wp_bucket.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.wp_profile.name
}
