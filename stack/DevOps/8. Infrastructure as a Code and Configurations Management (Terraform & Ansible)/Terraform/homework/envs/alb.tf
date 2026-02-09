resource "aws_lb" "this" {
  name               = "hw-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "foo" {
  name     = "tg-foo"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "bar" {
  name     = "tg-bar"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTP"
      port        = "80"
      path        = "/foo"
      host        = "#{host}"
      query       = "#{query}"
    }
  }
}

resource "aws_lb_listener_rule" "foo" {
  listener_arn = aws_lb_listener.http.arn
  priority = 10

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.foo.arn
  }

  condition {
    path_pattern {
      values = ["/foo*"]
    }
  }
}

resource "aws_lb_listener_rule" "bar" {
  listener_arn = aws_lb_listener.http.arn
  priority = 20

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.bar.arn
  }

  condition {
    path_pattern {
      values = ["/bar*"]
    }
  }
}
