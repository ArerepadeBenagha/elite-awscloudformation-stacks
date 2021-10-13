####-------- ALB -----------###
resource "aws_lb" "nginxlb" {
  name               = join("-", [local.application.app_name, "nginxlb"])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb-sg.id]
  subnets            = [data.aws_subnet.alb-public-1.id, data.aws_subnet.alb-public-2.id]
  idle_timeout       = "60"

  access_logs {
    bucket  = aws_s3_bucket.logs_s3.bucket
    prefix  = join("-", [local.application.app_name, "nginxlb-s3logs"])
    enabled = true
  }
  tags = merge(local.common_tags,
    { Name = "nginxserver"
  Application = "public" })
}
###------- ALB Health Check -------###
resource "aws_lb_target_group" "nginxapp_tglb" {
  name     = join("-", [local.application.app_name, "nginxapptglb"])
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc-stack.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    timeout             = "5"
    interval            = "30"
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "nginxapp_tglbat" {
  target_group_arn = aws_lb_target_group.nginxapp_tglb.arn
  target_id        = aws_instance.nginxserver.id
  port             = 80
}

####---- Redirect Rule -----####
resource "aws_lb_listener" "nginxapp_lblist" {
  load_balancer_arn = aws_lb.nginxlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
