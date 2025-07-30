#!/bin/bash

# AWS Deployment Script for AWS Architect Game
# This script deploys the application to AWS ECS using Fargate

set -e

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="aws-architect-game"
ECS_CLUSTER="aws-architect-game-cluster"
ECS_SERVICE="aws-architect-game-service"
TASK_DEFINITION="aws-architect-game"

echo "🚀 Starting AWS deployment process..."
echo "Account ID: $AWS_ACCOUNT_ID"
echo "Region: $AWS_REGION"

# Step 1: Build the Docker image
echo "📦 Building Docker image..."
docker build -f Dockerfile.production -t $ECR_REPOSITORY:latest .

# Step 2: Create ECR repository if it doesn't exist
echo "🏗️  Creating ECR repository..."
aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION || \
aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION

# Step 3: Login to ECR
echo "🔑 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Step 4: Tag and push image to ECR
echo "⬆️  Pushing image to ECR..."
docker tag $ECR_REPOSITORY:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# Step 5: Update task definition with correct values
echo "📝 Updating task definition..."
sed -i.bak "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" task-definition.json
sed -i.bak "s/REGION/$AWS_REGION/g" task-definition.json

# Step 6: Create CloudWatch log group
echo "📊 Creating CloudWatch log group..."
aws logs create-log-group --log-group-name /ecs/aws-architect-game --region $AWS_REGION || true

# Step 7: Register task definition
echo "📋 Registering task definition..."
aws ecs register-task-definition --cli-input-json file://task-definition.json --region $AWS_REGION

# Step 8: Create ECS cluster if it doesn't exist
echo "🏭 Creating ECS cluster..."
aws ecs create-cluster --cluster-name $ECS_CLUSTER --region $AWS_REGION || true

# Step 9: Create or update ECS service
echo "🌐 Creating/updating ECS service..."
aws ecs describe-services --cluster $ECS_CLUSTER --services $ECS_SERVICE --region $AWS_REGION > /dev/null 2>&1 && \
aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_SERVICE --task-definition $TASK_DEFINITION --region $AWS_REGION || \
aws ecs create-service \
  --cluster $ECS_CLUSTER \
  --service-name $ECS_SERVICE \
  --task-definition $TASK_DEFINITION \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-XXXXXXXXX],securityGroups=[sg-XXXXXXXXX],assignPublicIp=ENABLED}" \
  --region $AWS_REGION

echo "✅ Deployment completed successfully!"
echo "🌍 Your application should be accessible through the load balancer URL."
echo "📋 Check the ECS console for service status: https://console.aws.amazon.com/ecs/home?region=$AWS_REGION#/clusters/$ECS_CLUSTER/services"

# Restore original task definition
mv task-definition.json.bak task-definition.json
