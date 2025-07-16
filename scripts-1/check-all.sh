#!/bin/bash
set -e

echo "🚀 Run  pre-deploy checking."

./iam-ckecker.sh
./ecr-checker.sh
./kube-checker.sh

echo "All checkings are successfully."
