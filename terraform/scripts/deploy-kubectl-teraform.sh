#!/bin/bash

set -e

echo "Run: kubeconfig + terraform"

# kubeconfig
.terraform/configure-kubectl.sh

# init terraform
cd terraform
terraform init

# infra terraform
.terraform/run-terraform.sh
