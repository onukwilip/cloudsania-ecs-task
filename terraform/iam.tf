resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets_policy" {
  name = "ecs-task-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:us-east-1:173931218080:secret:ghcr-credentials-*"
      }
    ]
  })
}


resource "aws_iam_policy" "ecs_execution_minimal_policy" {
  name = "ecsExecutionMinimalPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowLogs",
        Effect = "Allow",
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_attach" {
  name       = "ecs-execution-attach"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_execution_minimal_policy.arn
}
