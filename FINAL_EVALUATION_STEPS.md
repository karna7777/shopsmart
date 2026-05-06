# ShopSmart Final Evaluation Steps

## What This Project Demonstrates

ShopSmart is a small React + Express application used to demonstrate a DevOps pipeline.

The final evaluation focus is:

- GitHub Actions CI
- Unit and integration testing
- Test report artifacts
- Terraform init, validate, and plan
- Docker multi-stage build
- Non-root container user
- Docker healthcheck
- AWS deployment through EC2
- GitHub Actions connecting to AWS/EC2 using secrets
- Idempotent deployment script

## Why EC2 Is Used

The rubric asks for ECS/ECR or EKS deployment, but the AWS Academy lab role denied these permissions:

- `s3:CreateBucket`
- `ecr:CreateRepository`
- `ecs:CreateCluster`
- IAM role creation/pass role actions for ECS task execution may also be denied
- `logs:CreateLogGroup`

Because students cannot edit the AWS Academy IAM role, this project keeps the ECS/ECR pipeline as code and uses EC2 as the working AWS deployment path.

Say this in evaluation:

> I implemented the ECS/ECR/Terraform path, but AWS Academy denied the required IAM actions. Since I cannot modify the lab role, I used GitHub Actions to deploy the Dockerized backend to EC2, which still demonstrates AWS deployment, Docker, secrets, and an idempotent deployment workflow.

If the evaluator requires strict Milestone 2 ECS/Fargate execution, the AWS role must allow S3, ECR, ECS, IAM, and CloudWatch Logs actions. With those permissions, set:

- `RUN_TERRAFORM_APPLY=true`
- `ENABLE_CONTAINER_SERVICES=true`
- `ENABLE_ECR_PUSH=true`

Then run `AWS ECS Pipeline` from GitHub Actions.

## GitHub Secrets Required

For AWS/Terraform validation:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`
- `TF_BUCKET_SUFFIX`

For EC2 deployment:

- `EC2_HOST`
- `EC2_USER`
- `EC2_SSH_KEY`

Use:

- `AWS_REGION=us-east-1`
- `EC2_USER=ubuntu` if the EC2 AMI is Ubuntu

## EC2 Setup In AWS Console

1. Open AWS Console.
2. Select region `N. Virginia / us-east-1`.
3. Go to `EC2`.
4. Click `Launch instance`.
5. Set name: `shopsmart-ec2`.
6. Select AMI: `Ubuntu`.
7. Select instance type: `t2.micro`.
8. Select key pair: `vockey`.
9. In security group inbound rules, allow:

```text
SSH        TCP 22    0.0.0.0/0
Custom TCP TCP 5001  0.0.0.0/0
```

10. Launch instance.
11. Copy the instance `Public IPv4 address`.
12. Add it to GitHub as `EC2_HOST`.

## GitHub EC2 Deployment

1. Go to GitHub repository.
2. Open `Actions`.
3. Click `AWS EC2 Deploy`.
4. Click `Run workflow`.
5. Select branch `main`.
6. Click `Run workflow`.

The workflow will:

- SSH into EC2
- Clone or update the repository
- Install Docker on Ubuntu
- Build the backend Docker image from `server/Dockerfile`
- Stop any old backend container
- Start a fresh backend container on port `5001`

## Verify Deployment

Open this in browser:

```text
http://EC2_PUBLIC_IPV4:5001/api/health
```

Expected output:

```json
{
  "status": "ok",
  "message": "ShopSmart Backend is running",
  "timestamp": "..."
}
```

## Screenshots To Take

Take these for final submission:

1. GitHub Actions `Project CI` passed.
2. GitHub Actions `AWS ECS Pipeline` showing tests, Terraform validate/plan, and Docker build.
3. GitHub Actions `AWS EC2 Deploy` passed.
4. EC2 instance running in AWS.
5. EC2 security group showing ports `22` and `5001`.
6. Browser showing `/api/health` from EC2 public IP.
7. `server/Dockerfile` showing multi-stage build, non-root user, and healthcheck.
8. `infra/terraform/main.tf` showing S3/ECR/ECS infrastructure code.
9. GitHub Secrets names page, without revealing secret values.
10. Failed AWS Academy permission log if asked why ECS/ECR was not fully deployed.

## Presentation Script

1. "This is ShopSmart, a React and Express application."
2. "The backend exposes `/api/health`, which is used by tests and Docker healthcheck."
3. "On every push and pull request, GitHub Actions runs linting, tests, and build."
4. "The workflow uploads test reports as artifacts."
5. "Terraform performs init, validate, and plan for infrastructure."
6. "Terraform apply for S3/ECR/ECS was blocked by AWS Academy IAM restrictions."
7. "To complete AWS deployment, I used GitHub Actions to deploy the Dockerized backend on EC2."
8. "The EC2 deploy script is idempotent: rerunning it updates the repo, rebuilds the image, removes the old container, and starts a new one."
9. "The Dockerfile uses multi-stage build, non-root user, and healthcheck."
10. "The deployed API is verified through the EC2 public IP on port `5001`."
