#!/bin/bash

CLUSTER_NAME="spring-petclinic-eks"
REGION="us-east-1"
IAM_USER_ARN=$(aws sts get-caller-identity --query Arn --output text)

echo "Add access Entry for user"
echo "$IAM_USER_ARN"

# add access
aws eks create-access-entry \
  --cluster-name "$CLUSTER_NAME" \
  --region "$REGION" \
  --principal-arn "$IAM_USER_ARN" \
  --type STANDARD

if [[ $? -eq 0 ]]; then
  echo "Access Entry is created."
else
  echo "Error for Access Entry."
fi
