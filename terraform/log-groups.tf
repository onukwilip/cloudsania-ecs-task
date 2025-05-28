# * FRONTEND LOG GROUP

resource "aws_cloudwatch_log_group" "frontend_logs" {
  name              = "/ecs/frontend"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

# * BACKEND A LOG GROUP

resource "aws_cloudwatch_log_group" "backend_a_logs" {
  name              = "/ecs/backend-a"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

# * BACKEND B LOG GROUP

resource "aws_cloudwatch_log_group" "backend_b_logs" {
  name              = "/ecs/backend-b"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}
