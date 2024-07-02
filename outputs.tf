output "aws_ses_email_arn" {
  value = aws_ses_email_identity.approved_email.arn
}

output "api_url" {
  value = aws_api_gateway_resource.home.path
}