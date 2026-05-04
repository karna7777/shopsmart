locals {
  safe_bucket_suffix = lower(trimspace(var.bucket_suffix))
  name_prefix        = "${var.project_name}-${local.safe_bucket_suffix}"
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-artifacts"
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ecr_repository" "backend" {
  count = var.enable_container_services ? 1 : 0

  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "main" {
  count = var.enable_container_services ? 1 : 0

  name = "${var.project_name}-cluster"
}

resource "aws_cloudwatch_log_group" "backend" {
  count = var.enable_container_services ? 1 : 0

  name              = "/ecs/${var.project_name}-backend"
  retention_in_days = 7
}
