output "dvc_s3_bucket" {
  description = "Name of the S3 bucket for DVC storage"
  value       = aws_s3_bucket.dvc_storage.bucket
}

output "mlflow_s3_bucket" {
  description = "Name of the S3 bucket for MLflow artifacts"
  value       = aws_s3_bucket.mlflow_artifacts.bucket
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the security group for EC2 instances"
  value       = aws_security_group.ec2_sg.id
}

output "iam_instance_profile" {
  description = "Name of the IAM instance profile for EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}