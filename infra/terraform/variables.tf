variable "aws_region" {
  description = "AWS region used for the project resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short lowercase project name used in AWS resource names."
  type        = string
  default     = "shopsmart"
}

variable "bucket_suffix" {
  description = "Unique suffix for the S3 bucket name, such as your roll number."
  type        = string
}

variable "enable_container_services" {
  description = "Set true only when the AWS account allows ECR, ECS, and CloudWatch Logs creation."
  type        = bool
  default     = false
}

variable "container_image_tag" {
  description = "Docker image tag used by the ECS task definition."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the backend container."
  type        = number
  default     = 5001
}
