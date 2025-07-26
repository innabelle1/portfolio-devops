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

# check CLI
if [ ! -f "$JENKINS_CLI_JAR" ]; then
  echo "jenkins-cli.jar not found:"
  echo "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
  exit 1
fi

# run jobs
for service in "${services[@]}"; do
  echo "run jobs for: petclinic-${service}"

  java -jar "$JENKINS_CLI_JAR" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" \
    build "petclinic-${service}" \
    -w || echo "Failure: petclinic-${service}"
done

echo "all pipelines in  Jenkins"
