provider "aws" {
  region = "us-east-2"
}

# Create an S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-tf-test-bucket025" # Ensure this bucket name is unique

  tags = {
    Name        = "My bucket25"
    Environment = "Dev"
  }
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Block all Public Access to the S3 Bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a CloudFront Origin Access Identity (OAI) to Restrict Access to S3
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for accessing ${aws_s3_bucket.my_bucket.bucket}"
}

# Attach a Policy to Allow CloudFront to Read from S3
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

# Create a CloudFront Distribution for Secure Access
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = aws_cloudfront_cache_policy.default.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # ✅ Fix: Add the required restrictions block
  restrictions {
    geo_restriction {
      restriction_type = "none" # Change to "whitelist" or "blacklist" if restricting certain regions
    }
  }
}

# Create a CloudFront Cache Policy
resource "aws_cloudfront_cache_policy" "default" {
  name        = "default-cache-policy"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Create index.html file with "Hello, World!"
resource "local_file" "index_html" {
  filename = "${path.module}/index.html"
  content  = <<EOF
  <!DOCTYPE html>
  <html>
  <head>
      <title>My S3 Website</title>
  </head>
  <body>
      <h1>Hello, World!</h1>
      <p>Welcome to my static website hosted on S3 and served via CloudFront!</p>
  </body>
  </html>
  EOF
}

# Upload index.html to S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = local_file.index_html.filename
  content_type = "text/html"
}

# Upload error.html to S3
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "error.html"
  source       = local_file.index_html.filename
  content_type = "text/html"
}

# Output the CloudFront URL
output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
  description = "Access your website through CloudFront"
}
