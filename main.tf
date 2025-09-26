resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  content_type = "text/css"
}
resource "aws_s3_bucket_public_access_block" "website_public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website" {
  bucket = "static-website-hosting-bucket-${random_id.suffix.hex}"
  # acl removed due to ObjectOwnership enforcement

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "static-website-logs-bucket-${random_id.suffix.hex}"
  # acl removed due to ObjectOwnership enforcement
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "${path.module}/index.html"
  # acl removed due to BucketOwnerEnforced setting
  content_type = "text/html"
}

output "website_endpoint" {
  value = aws_s3_bucket.website.website_endpoint
  description = "S3 static website endpoint URL"
}
