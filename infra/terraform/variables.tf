variable "aws_region" {
  description = "AWS region used for the project resources."
  type        = string
  default     = "ap-south-1"
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
