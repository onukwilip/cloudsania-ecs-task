# * EXTERNAL LB

resource "aws_lb" "external_alb" {
  name               = "external-alb"
  internal           = false # public-facing
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.alb_sg_external.id]
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # for ECS tasks

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "external_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# * INTERNAL LB

resource "aws_lb" "internal_alb" {
  name               = "cloudsania-ecs-internal-alb"
  internal           = true # internal only
  load_balancer_type = "application"
  subnets            = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_groups    = [aws_security_group.alb_sg_internal.id]
}

resource "aws_lb_target_group" "backend_a_tg" {
  name        = "backend-a-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "backend_b_tg" {
  name        = "backend-b-tg"
  port        = 6000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  # We'll route requests based on the Host header or path; but since your
  # flow is routing by port, let's implement listener rules to match that.

  default_action {
    # Could default to backend-a or return fixed response
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No matching rule found"
      status_code  = "404"
    }
  }
}

# Listener rules for port-based routing on internal ALB
# Unfortunately, ALB listeners listen on specific ports, not multiplex ports inside one listener.
# So, we will need two listeners, one for port 5000 and one for port 6000 on internal ALB.

resource "aws_lb_listener" "internal_listener_backend_a" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_a_tg.arn
  }
}

resource "aws_lb_listener" "internal_listener_backend_b" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 6000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_b_tg.arn
  }
}
