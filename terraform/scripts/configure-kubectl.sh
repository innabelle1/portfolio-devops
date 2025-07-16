#!/bin/bash

CLUSTER_NAME="spring-petclinic-eks"
REGION="us-east-1"

#Settings kubeconfig cluster EKS

# check  AWS CLI
if ! command -v aws &>/dev/null; then
  echo "AWS CLI isnt install."
  exit 1
fi

# check  kubectl
if ! command -v kubectl &>/dev/null; then
  echo "kubectl isnt install."
  exit 1
fi

# update kubeconfig
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

if [ $? -eq 0 ]; then
  echo "kubeconfig is install."
  echo "check connection to cluster..."
  kubectl get nodes
else
  echo "Isnt update kubeconfig. Check IAM-access or cluster name."
  exit 1
fi
