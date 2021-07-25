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
