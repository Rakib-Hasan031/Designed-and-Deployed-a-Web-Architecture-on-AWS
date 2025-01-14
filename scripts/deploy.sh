#!/bin/bash

# Exit on error
set -e

# Deploy VPC Stack
echo "Deploying VPC Stack..."
aws cloudformation create-stack \
  --stack-name vpc-stack \
  --template-body file://../templates/vpc.yaml \
  --capabilities CAPABILITY_IAM

# Wait for VPC stack to complete
echo "Waiting for VPC stack to complete..."
aws cloudformation wait stack-create-complete --stack-name vpc-stack

# Get VPC outputs
VPC_ID=$(aws cloudformation describe-stacks --stack-name vpc-stack --query 'Stacks[0].Outputs[?ExportName==`vpc-stack-VPCID`].OutputValue' --output text)
PUBLIC_SUBNETS=$(aws cloudformation describe-stacks --stack-name vpc-stack --query 'Stacks[0].Outputs[?ExportName==`vpc-stack-PublicSubnets`].OutputValue' --output text)
PRIVATE_SUBNETS=$(aws cloudformation describe-stacks --stack-name vpc-stack --query 'Stacks[0].Outputs[?ExportName==`vpc-stack-PrivateSubnets`].OutputValue' --output text)

# Deploy Security Stack
echo "Deploying Security Stack..."
aws cloudformation create-stack \
  --stack-name security-stack \
  --template-body file://../templates/security.yaml \
  --parameters ParameterKey=VpcId,ParameterValue=$VPC_ID

# Wait for Security stack to complete
echo "Waiting for Security stack to complete..."
aws cloudformation wait stack-create-complete --stack-name security-stack

# Get Security Group outputs
LB_SG=$(aws cloudformation describe-stacks --stack-name security-stack --query 'Stacks[0].Outputs[?ExportName==`security-stack-LoadBalancerSG`].OutputValue' --output text)
APP_SG=$(aws cloudformation describe-stacks --stack-name security-stack --query 'Stacks[0].Outputs[?ExportName==`security-stack-ApplicationSG`].OutputValue' --output text)

# Deploy Application Stack
echo "Deploying Application Stack..."
aws cloudformation create-stack \
  --stack-name application-stack \
  --template-body file://../templates/application.yaml \
  --parameters \
    ParameterKey=VpcId,ParameterValue=$VPC_ID \
    ParameterKey=PublicSubnets,ParameterValue=\"$PUBLIC_SUBNETS\" \
    ParameterKey=PrivateSubnets,ParameterValue=\"$PRIVATE_SUBNETS\" \
    ParameterKey=LoadBalancerSG,ParameterValue=$LB_SG \
    ParameterKey=ApplicationSG,ParameterValue=$APP_SG

# Wait for Application stack to complete
echo "Waiting for Application stack to complete..."
aws cloudformation wait stack-create-complete --stack-name application-stack

# Get Load Balancer DNS
LB_DNS=$(aws cloudformation describe-stacks --stack-name application-stack --query 'Stacks[0].Outputs[?ExportName==`application-stack-LoadBalancerDNS`].OutputValue' --output text)

echo "Deployment complete!"
echo "Load Balancer DNS: $LB_DNS"