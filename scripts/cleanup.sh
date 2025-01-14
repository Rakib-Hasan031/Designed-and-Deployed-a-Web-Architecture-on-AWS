#!/bin/bash

# Exit on error
set -e

# Delete Application Stack
echo "Deleting Application Stack..."
aws cloudformation delete-stack --stack-name application-stack

# Wait for Application stack deletion
echo "Waiting for Application stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name application-stack

# Delete Security Stack
echo "Deleting Security Stack..."
aws cloudformation delete-stack --stack-name security-stack

# Wait for Security stack deletion
echo "Waiting for Security stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name security-stack

# Delete VPC Stack
echo "Deleting VPC Stack..."
aws cloudformation delete-stack --stack-name vpc-stack

# Wait for VPC stack deletion
echo "Waiting for VPC stack deletion..."
aws cloudformation wait stack-delete-complete --stack-name vpc-stack

echo "Cleanup complete! All resources have been deleted."