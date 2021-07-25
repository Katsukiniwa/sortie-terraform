resource "aws_lb" "elb" {
  name = "elb"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public-a.id,
    aws_subnet.public_c.id,
  ]

  access_logs {
    bucket = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.elb.dns_name
}

module "http_sg" {
  source = "./security_group"
  name = "express-ecs-staging-http-sg"
  vpc_id = aws_vpc.vpc.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source = "./security_group"
  name = "express-ecs-staging-https-sg"
  vpc_id = aws_vpc.vpc.id
  port = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source = "./security_group"
  name = "express-ecs-staging-http-redirect-sg"
  vpc_id = aws_vpc.vpc.id
  port = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これはHTTPです"
      status_code = "200"
    }
  }
}
