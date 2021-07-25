variable "staging-s3-bucket-name" {
  default = "express-ecs-staging-bucket"
}

resource "aws_s3_bucket" "public" {
  bucket = var.staging-s3-bucket-name
  acl = "public-read"
  force_destroy = true

  cors_rule {
    allowed_origins = [ "*" ]
    allowed_methods = ["GET"]
    allowed_headers = [ "*" ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "express-ecs-staging-alb-log"
  
  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      identifiers = ["582318560864"]
    }
  }
}
