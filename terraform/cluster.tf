resource "aws_ecs_cluster" "main" {
  name = "cloudsania-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    environment = "prod"
    name        = "cloudsania-cluster"
  }
}
