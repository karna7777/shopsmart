output "artifact_bucket_name" {
  description = "S3 bucket with versioning, encryption, and public access block enabled."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL for the backend Docker image when container services are enabled."
  value       = var.enable_container_services ? aws_ecr_repository.backend[0].repository_url : "disabled-by-default"
}

output "ecs_cluster_name" {
  description = "ECS cluster name when container services are enabled."
  value       = var.enable_container_services ? aws_ecs_cluster.main[0].name : "disabled-by-default"
}

output "ecs_service_name" {
  description = "ECS Fargate service name when container services are enabled."
  value       = var.enable_container_services ? aws_ecs_service.backend[0].name : "disabled-by-default"
}

output "ecs_security_group_id" {
  description = "Security group allowing access to the ECS backend service."
  value       = var.enable_container_services ? aws_security_group.backend[0].id : "disabled-by-default"
}
