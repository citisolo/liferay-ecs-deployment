output "alb_dns_name" {
  value = aws_alb.liferay_alb.dns_name
  description = "The DNS name of the ALB for accessing the Liferay application"
}