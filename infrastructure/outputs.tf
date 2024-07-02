output "api_url" {
  value = aws_api_gateway_resource.home.path
}

output "web_url" {
  value = aws_s3_bucket.my-static-website.bucket_domain_name
}