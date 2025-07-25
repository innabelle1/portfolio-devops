#!/bin/bash

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN="admin123"
JENKINS_CLI_JAR="./jenkins-cli.jar"

# list services
services=(
  "config-server"
  "discovery-server"
  "customers-service"
  "visits-service"
  "vets-service"
  "genai-service"
  "api-gateway"
  "admin-server"
)

# run jobs
for service in "${services[@]}"; do
  echo "run jobs for: petclinic-${service}"

  java -jar "$JENKINS_CLI_JAR" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" \
    build "petclinic-${service}" \
    -p "SERVICE_NAME=${service}" \
    -p "IMAGE_TAG=latest" \
    -w || echo "Failure: petclinic-${service}"
done

echo "all pipelines in  Jenkins"
