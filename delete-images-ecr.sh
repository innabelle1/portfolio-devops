#!/bin/bash

REGION="us-east-1"
REPOS=$(aws ecr describe-repositories --region $REGION --query 'repositories[?starts_with(repositoryName, `petclinic/`)].repositoryName' --output text)

for REPO in $REPOS; do
  IMAGES=$(aws ecr list-images \
    --repository-name "$REPO" \
    --region "$REGION" \
    --query 'imageIds[*]' \
    --output json)

  if [[ $IMAGES != "[]" ]]; then
    echo "Delete images from $REPO..."
    aws ecr batch-delete-image \
      --repository-name "$REPO" \
      --region "$REGION" \
      --image-ids "$IMAGES"
  else
  echo "There are no images in $REPO"
  fi

  echo "Ready from $REPO"
done

echo "All images  petclinic-repository are deleted."
