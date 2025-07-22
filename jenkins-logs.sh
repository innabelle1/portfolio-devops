#!/bin/bash

services=(
  petclinic-config-server
  petclinic-discovery-server
  petclinic-customers-service
  petclinic-visits-service
  petclinic-vets-service
  petclinic-genai-service
  petclinic-api-gateway
  petclinic-admin-server
)

for job in "${services[@]}"; do
  echo -e "\n--- $job"
  ./jenkins-cli.sh -auth @~/.netrc console "$job" 2>/dev/null | tail -n 30
done
