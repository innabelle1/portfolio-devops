#!/bin/bash

set -e

AWS_REGION="us-east-1"
REPOSITORIES=(
  "petclinic/config-server"
  "petclinic/discovery-server"
  "petclinic/customers-service"
  "petclinic/visits-service"
  "petclinic/vets-service"
  "petclinic/genai-service"
  "petclinic/api-gateway"
  "petclinic/admin-server"
)

echo "Check ECR repository in region: $AWS_REGION"

for repo in "${REPOSITORIES[@]}"; do
  echo -n "🔎 $repo ... "
  if aws ecr describe-repositories --repository-names "$repo" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo "Exist"
  else
    echo "Not found"
  fi
done
