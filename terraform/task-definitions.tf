# * FRONTEND TASK DEFINITION

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "ghcr.io/onukwilip/meshery-practice-frontend:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ],
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.ghcr_credentials.arn
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      },
      environment = [
        {
          name  = "BACKEND_A"
          value = "http://${aws_lb.internal_alb.dns_name}:5000"
        },
        {
          name  = "BACKEND_B"
          value = "http://${aws_lb.internal_alb.dns_name}:6000"
        }
      ]
    }
  ])
}

# * BACKEND A TASK DEFINITION

resource "aws_ecs_task_definition" "backend_a" {
  family                   = "backend-a-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend-a"
      image = "ghcr.io/onukwilip/meshery-practice-backend-a:latest"
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.ghcr_credentials.arn
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend_a_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      },
      environment = [
        {
          name  = "BACKEND_A"
          value = "http://${aws_lb.internal_alb.dns_name}:5000"
        },
        {
          name  = "BACKEND_B"
          value = "http://${aws_lb.internal_alb.dns_name}:6000"
        }
      ]
    }
  ])
}

# * BACKEND B TASK DEFINITION

resource "aws_ecs_task_definition" "backend_b" {
  family                   = "backend-b-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend-b"
      image = "ghcr.io/onukwilip/meshery-practice-backend-b:latest"
      portMappings = [
        {
          containerPort = 6000
          hostPort      = 6000
        }
      ],
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.ghcr_credentials.arn
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend_b_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      },
      environment = [
        {
          name  = "BACKEND_A"
          value = "http://${aws_lb.internal_alb.dns_name}:5000"
        },
        {
          name  = "BACKEND_B"
          value = "http://${aws_lb.internal_alb.dns_name}:6000"
        }
      ]
    }
  ])
}
