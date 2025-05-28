variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ghcr_token" {
  description = "PAT for the GitHub Container Registry"
  type        = string
}
