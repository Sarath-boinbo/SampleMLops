terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for DVC data storage (Free Tier: 5GB storage, 20,000 GET/2,000 PUT requests)
resource "aws_s3_bucket" "dvc_storage" {
  bucket = "${var.project_name}-dvc-storage-${random_string.bucket_suffix.result}"
}

# S3 Bucket for MLflow artifacts (Free Tier: 5GB storage, 20,000 GET/2,000 PUT requests)
resource "aws_s3_bucket" "mlflow_artifacts" {
  bucket = "${var.project_name}-mlflow-artifacts-${random_string.bucket_suffix.result}"
}

# ECR Repository for Docker images (Free Tier: 500MB storage)
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false  # Disabled to stay within free tier
  }
}

# Random string for unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# We'll use local Kubernetes (minikube/kind) instead of EKS for free tier
# EKS control plane costs $0.10/hour (~$72/month), not included in free tier