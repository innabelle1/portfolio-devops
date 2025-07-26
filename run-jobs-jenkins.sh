#!/bin/bash

JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN="admin123"
JENKINS_CLI="./jenkins-cli.jar"

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

# git commit
GIT_COMMIT=$(git rev-parse HEAD)
echo "Current GIT_COMMIT: $GIT_COMMIT"
echo

# check Jenkins CLI
if [ ! -f "$JENKINS_CLI" ]; then
  echo "Downloading jenkins-cli.jar..."
  curl -sSL "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -o "$JENKINS_CLI"
fi

# run pipelines
for service in "${services[@]}"; do
  echo "Run pipeline for: petclinic-$service"

  java -jar "$JENKINS_CLI" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" \
    build "petclinic-$service" \
    -p "SERVICE_NAME=$service" \
    -p "GIT_COMMIT=$GIT_COMMIT" \
    -w || echo "Run failure: petclinic-$service"

done

echo "All pipeline's are running with tag: $GIT_COMMIT"
