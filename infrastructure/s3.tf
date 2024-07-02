resource "aws_s3_bucket" "my-static-website" {
  bucket = "my-static-website-asdlfk203"
}

resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}
# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "my-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my-static-website,
    aws_s3_bucket_public_access_block.my-static-website,
  ]

  bucket = aws_s3_bucket.my-static-website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "my-static-website-policy" {
  bucket = aws_s3_bucket.my-static-website.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.my-static-website.id}/*"
        ]
      }
    ]
  })
  depends_on = [
    aws_s3_bucket_ownership_controls.my-static-website,
    aws_s3_bucket_public_access_block.my-static-website,
  ]
}

# module "template_files" {
#   source = "hashicorp/dir/template"

#   base_dir = "${path.module}/webapp"
# }

# resource "aws_s3_object" "FrontEndFolder" {
#   bucket = aws_s3_bucket.my-static-website.id

#   for_each     = module.template_files.files
#   key          = each.key
#   content_type = each.value.content_type
#   source       = each.value.source_path
#   content      = each.value.content
#   etag         = each.value.digests.md5
# }