# ShopSmart Terraform

This folder covers the infrastructure-provisioning part of the DevOps rubric.

It creates by default:

- An S3 artifact bucket with a unique name
- S3 versioning
- S3 server-side encryption
- S3 public access block

It can also create ECR, ECS Fargate, CloudWatch Logs, security group, task definition, and service if your AWS account allows those services:

```bash
terraform apply \
  -var="bucket_suffix=your-roll-number" \
  -var="enable_container_services=true"
```

In AWS Academy labs, S3/ECR/ECS/IAM/CloudWatch permissions can be blocked, so container services are disabled by default.

Run locally only after configuring AWS credentials:
<!--  RUNNING THE FORMAT -->
```bash
cd infra/terraform
terraform init
terraform validate
terraform plan -var="bucket_suffix=your-roll-number"
terraform apply -var="bucket_suffix=your-roll-number"
```

Use a unique `bucket_suffix`, because S3 bucket names must be globally unique.
