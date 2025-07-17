#!/bin/bash

set -e

# logs file
#TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
#LOG_DIR="../logs"
#LOG_FILE="$LOG_DIR/terraform-$TIMESTAMP.log"

# terraform/main.tf
TF_DIR="terraform"


#mkdir -p "$LOG_DIR"
#{
echo "Directory Terraform project: $TF_DIR"
cd "$TF_DIR"

echo "Init Terraform..."
terraform init -upgrade 

echo "Check syntac..."
terraform validate

#echo "Changes plan..."
terraform plan -out=tfplan

#terraform plan

#echo "Apply changes..."
terraform apply -auto-approve tfplan 

echo "Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name spring-petclinic-eks


echo "Verifying nodes..."
kubectl get nodes
kubectl get pods -A

#terraform apply
echo "Infrastructure deply is READY!"
#} | tee "$LOG_FILE"
