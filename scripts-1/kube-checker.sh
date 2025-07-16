#!/bin/bash
set -e

CLUSTER_NAME="spring-petclinic-eks"
AWS_REGION="us-east-1"

echo "Check connection to EKS cluster: $CLUSTER_NAME"
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "Check kubectl access."
kubectl get nodes
kubectl get pods -A
