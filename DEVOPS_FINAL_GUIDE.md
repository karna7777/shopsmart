# ShopSmart DevOps Final Guide

## What to Say First

ShopSmart is a simple full-stack project used to demonstrate a DevOps pipeline. The focus of this final evaluation is not database complexity. The focus is automated testing, CI/CD, Docker, infrastructure provisioning, AWS deployment, and explaining the workflow clearly.

## Architecture

Frontend:

- React app in `client/`
- Calls the backend health API
- Can be deployed separately on Vercel, Render Static, or S3/CloudFront

Backend:

- Express app in `server/`
- Exposes `/api/health`
- Packaged as a Docker image for AWS deployment

DevOps:

- GitHub Actions runs tests and lint checks
- Terraform provisions AWS resources
- Docker builds the backend image
- ECR stores the image
- ECS or EC2 runs the deployed backend

## Rubric Mapping

Regularity:

- Use small commits for Docker, Terraform, CI, and docs.
- Avoid one large final commit.

GitHub Workflows / CI:

- `.github/workflows/aws-ecs-pipeline.yml`
- Runs on `push`, `pull_request`, and manual dispatch.
- Installs dependencies, lints backend, tests backend/frontend, generates test reports, and builds frontend.

Frontend:

- React code is in `client/`.
- It calls `/api/health` and shows backend status.

Unit Testing:

- Backend test is in `server/tests/app.test.js`.
- Frontend test is in `client/src/App.test.jsx`.
- Test reports are uploaded as GitHub Actions artifacts.

Integration Testing:

- Backend test uses Supertest to call the Express API.

E2E Testing:

- Optional bonus. Add Playwright later if needed.

PR Checks:

- Pull requests trigger the workflow.
- Bad tests or lint failures block the PR.

Dependabot:

- `.github/dependabot.yml` checks backend, frontend, and GitHub Actions dependencies.

AWS EC2 / GitHub Integration:

- `scripts/ec2-deploy.sh` is an idempotent deployment script for EC2.
- `.github/workflows/aws-ec2-deploy.yml` SSHs into EC2 and runs this script.

Terraform:

- `infra/terraform/` provisions the S3 bucket by default.
- S3 has versioning, encryption, and public access blocked.
- ECR, ECS, and CloudWatch are optional because AWS Academy accounts may deny those permissions.

Docker:

- `server/Dockerfile` uses multi-stage build.
- It runs as a non-root user.
- It includes a health check.

## GitHub Secrets Needed

Add these in GitHub:

`Settings -> Secrets and variables -> Actions -> New repository secret`

Required for AWS:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`
- `TF_BUCKET_SUFFIX`
- `RUN_TERRAFORM_APPLY`

Optional for ECS service redeploy:

- `ECS_SERVICE`
- `ENABLE_ECR_PUSH`

For EC2 deployment:

- `EC2_HOST`
- `EC2_USER`
- `EC2_SSH_KEY`

## EC2 Deployment Steps

Use this route if your evaluator asks specifically for GitHub Actions connected to EC2.

1. Launch an EC2 Ubuntu instance.
2. Open inbound ports in the EC2 security group:
   - SSH: `22`
   - Backend: `5001`
3. SSH into EC2 once and install Node.js, Git, and PM2.
4. Add your EC2 private key, host, and user to GitHub Secrets.
5. Go to GitHub Actions.
6. Open `AWS EC2 Deploy`.
7. Click `Run workflow`.
8. Test the backend:

```bash
curl http://your-ec2-public-ip:5001/api/health
```

## Beginner AWS Deployment Path

### Step 1: Create AWS Credentials

Use your AWS Academy or AWS account credentials. Add the access key, secret key, session token, and region to GitHub Secrets.

### Step 2: Run Terraform

The workflow runs Terraform init, validate, and plan automatically after a push to `main`.

Terraform apply runs only when this GitHub secret is set:

`RUN_TERRAFORM_APPLY=true`

In restricted AWS Academy labs, leave it unset or set it to `false`, because the lab role may deny `s3:CreateBucket`.

Terraform creates:

- S3 bucket
- S3 versioning
- S3 encryption
- S3 public access block

ECR, ECS, and CloudWatch can be enabled only if your AWS role allows them. If AWS returns `AccessDeniedException` for ECR/ECS/CloudWatch, keep `ENABLE_ECR_PUSH` unset and use the EC2 deployment route for the AWS deployment demo.

For strict Milestone 2 grading, the intended path is:

1. Terraform creates S3, ECR, ECS Fargate, task definition, service, security group, IAM task execution role, and CloudWatch logs.
2. GitHub Actions builds the backend Docker image.
3. GitHub Actions pushes the image to ECR.
4. GitHub Actions forces a new ECS service deployment.

This requires AWS permissions for S3, ECR, ECS, IAM PassRole, and CloudWatch Logs. For AWS Academy, Terraform reuses the existing `LabRole` instead of creating a new IAM role because `iam:CreateRole` is denied for students.

### Step 3: Build Docker Image

GitHub Actions builds the Docker image from `server/Dockerfile`.

### Step 4: Build Docker Image

The workflow builds the backend Docker image in GitHub Actions.

If your AWS account allows ECR and you set `ENABLE_ECR_PUSH=true`, it also pushes the image to Amazon ECR with two tags:

- Git commit SHA
- `latest`

### Step 5: Deploy

For mid-evaluation recovery, explain either:

- ECS path: image in ECR, ECS cluster created, service redeployed
- EC2 path: GitHub Actions SSHs into EC2 and runs an idempotent deploy script

## Presentation Script

1. "My project is ShopSmart, and I used it to demonstrate a DevOps pipeline."
2. "The frontend is React and the backend is Express."
3. "The backend exposes a health endpoint used for testing and Docker health checks."
4. "On every push or pull request, GitHub Actions installs dependencies, runs lint, runs tests, and builds the app."
5. "Terraform provisions AWS infrastructure like S3, ECR, ECS cluster, and CloudWatch logs."
6. "The Dockerfile uses a multi-stage build, non-root user, and a health check."
7. "GitHub Actions authenticates with AWS using repository secrets."
8. "The image is pushed to ECR and can be deployed to ECS or EC2."
9. "The EC2 script is idempotent because it can be run multiple times safely."
10. "The main challenge was connecting local development, GitHub Actions, Docker, and AWS into one workflow."
