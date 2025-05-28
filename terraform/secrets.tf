resource "aws_secretsmanager_secret" "ghcr_credentials" {
  name = "ghcr-credentials"
}

resource "aws_secretsmanager_secret_version" "ghcr_credentials_version" {
  secret_id = aws_secretsmanager_secret.ghcr_credentials.id
  secret_string = jsonencode({
    username = "onukwilip"
    password = var.ghcr_token
  })
}
