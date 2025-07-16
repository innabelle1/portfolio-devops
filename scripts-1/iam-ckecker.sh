#!/bin/bash
set -e

echo "Check access to  AWS (IAM)"
aws sts get-caller-identity
