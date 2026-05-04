output "artifact_bucket_name" {
  description = "S3 bucket with versioning, encryption, and public access block enabled."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL for the backend Docker image."
  value       = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster created for the project."
  value       = aws_ecs_cluster.main.name
}
