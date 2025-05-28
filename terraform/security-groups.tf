# * LOAD BALANCERS

resource "aws_security_group" "alb_sg_external" {
  name        = "alb-sg-external"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "alb_sg_internal" {
  name        = "alb-sg-internal"
  description = "Internal ALB access to backends"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id, aws_security_group.alb_sg_external.id]
    description     = "Allow frontend to access backend-a via ALB"
  }

  ingress {
    from_port       = 6000
    to_port         = 6000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id, aws_security_group.alb_sg_external.id]
    description     = "Allow frontend to access backend-b via ALB"
  }
}

# * SERVICES

resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow traffic from ALB and to backends"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_a_sg" {
  name        = "backend-a-sg"
  description = "Allow internal comms from internal LB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.alb_sg_internal.id,
      aws_security_group.frontend_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_b_sg" {
  name        = "backend-b-sg"
  description = "Allow internal comms from internal LB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 6000
    to_port   = 6000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.alb_sg_internal.id,
      aws_security_group.frontend_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# * SG RULES

# Ingress to ALB from the internet
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg_external.id
}

# Egress from ALB to frontend
resource "aws_security_group_rule" "alb_to_frontend" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb_sg_external.id
  source_security_group_id = aws_security_group.frontend_sg.id
}

# Ingress to frontend from ALB
resource "aws_security_group_rule" "frontend_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.alb_sg_external.id
}

# ! REMOVE

# Start
resource "aws_security_group_rule" "frontend_to_internal_alb_backend_a" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.alb_sg_internal.id
}

resource "aws_security_group_rule" "frontend_to_internal_alb_backend_b" {
  type                     = "egress"
  from_port                = 6000
  to_port                  = 6000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.alb_sg_internal.id
}

resource "aws_security_group_rule" "frontend_to_backend_a" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.backend_a_sg.id
}

resource "aws_security_group_rule" "frontend_to_backend_b" {
  type                     = "egress"
  from_port                = 6000
  to_port                  = 6000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.backend_b_sg.id
}

resource "aws_security_group_rule" "frontend_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.frontend_sg.id
}
# End

# # Egress from ALB to backend-a
# resource "aws_security_group_rule" "alb_internal_to_backend_a" {
#   type                     = "egress"
#   from_port                = 5000
#   to_port                  = 5000
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb_sg_internal.id
#   source_security_group_id = aws_security_group.backend_a_sg.id
# }

# # Egress from ALB to backend-b
# resource "aws_security_group_rule" "alb_internal_to_backend_b" {
#   type                     = "egress"
#   from_port                = 6000
#   to_port                  = 6000
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb_sg_internal.id
#   source_security_group_id = aws_security_group.backend_b_sg.id
# }

# Egress from ALB to VPC (internal communication)
resource "aws_security_group_rule" "alb_internal_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.alb_sg_internal.id
}
