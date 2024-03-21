output "alb_dns_name" {
  value = aws_alb.liferay_alb.dns_name
  description = "The DNS name of the ALB for accessing the Liferay application"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.lambda_trigger_bucket.bucket
  description = "The name of the S3 bucket for the Lambda trigger"
}