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

# Upload index.html to S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html" # destination file name in the bucket
  source       = "${path.module}/index.html" # local file path
  content_type = "text/html"
}


# Upload error.html to S3
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
}