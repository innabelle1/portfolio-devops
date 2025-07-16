#!/bin/bash

set -e

TF_DIR="infra/terraform"
CLUSTER_NAME="spring-petclinic-eks"
REGION="us-east-1"

echo "🚀 Deploy Terraform..."
cd $TF_DIR
terraform init -upgrade
terraform apply -auto-approve

echo "✅ Update kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "🚀 Apply Karpenter Provisioner..."
kubectl apply -f ../..terraform/provisioner.yaml

echo "🎉 Karpenter is ready!"
