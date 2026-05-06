locals {
  safe_bucket_suffix = lower(trimspace(var.bucket_suffix))
  safe_deployment_id = lower(trimspace(var.deployment_id))
  name_prefix        = "${var.project_name}-${local.safe_deployment_id}-${local.safe_bucket_suffix}"
  backend_image      = var.enable_container_services ? "${aws_ecr_repository.backend[0].repository_url}:${var.container_image_tag}" : "disabled"
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

  name                 = "${var.project_name}-${local.safe_deployment_id}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "main" {
  count = var.enable_container_services ? 1 : 0

  name = "${var.project_name}-${local.safe_deployment_id}-cluster"
}

resource "aws_cloudwatch_log_group" "backend" {
  count = var.enable_container_services ? 1 : 0

  name              = "/ecs/${var.project_name}-${local.safe_deployment_id}-backend"
  retention_in_days = 7
}

data "aws_vpc" "default" {
  count = var.enable_container_services ? 1 : 0

  default = true
}

data "aws_subnets" "default" {
  count = var.enable_container_services ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

data "aws_iam_role" "lab_role" {
  count = var.enable_container_services ? 1 : 0

  name = "LabRole"
}

resource "aws_security_group" "backend" {
  count = var.enable_container_services ? 1 : 0

  name        = "${var.project_name}-${local.safe_deployment_id}-backend-sg"
  description = "Allow public HTTP access to the ShopSmart backend container."
  vpc_id      = data.aws_vpc.default[0].id

  ingress {
    description = "Backend API"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "backend" {
  count = var.enable_container_services ? 1 : 0

  family                   = "${var.project_name}-${local.safe_deployment_id}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab_role[0].arn
  task_role_arn            = data.aws_iam_role.lab_role[0].arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${local.safe_deployment_id}-backend"
      image     = local.backend_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://127.0.0.1:${var.container_port}/api/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend[0].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  count = var.enable_container_services ? 1 : 0

  name            = "${var.project_name}-${local.safe_deployment_id}-backend-service"
  cluster         = aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.backend[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default[0].ids
    security_groups  = [aws_security_group.backend[0].id]
    assign_public_ip = true
  }
}
