#!/bin/bash

set -e

echo "Run: kubeconfig + terraform"

# kubeconfig
.infra/terraform/configure-kubectl.sh

# init terraform
cd infra/terraform
terraform init

# infra terraform
.infra/terraform/run-terraform.sh
