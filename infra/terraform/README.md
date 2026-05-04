# ShopSmart Terraform

This folder covers the infrastructure-provisioning part of the DevOps rubric.

It creates:

- An S3 artifact bucket with a unique name
- S3 versioning
- S3 server-side encryption
- S3 public access block
- An ECR repository for Docker images
- An ECS cluster
- A CloudWatch log group

Run locally only after configuring AWS credentials:

```bash
cd infra/terraform
terraform init
terraform validate
terraform plan -var="bucket_suffix=your-roll-number"
terraform apply -var="bucket_suffix=your-roll-number"
```

Use a unique `bucket_suffix`, because S3 bucket names must be globally unique.
