#!/bin/bash
set -e

echo "Stopping old Jenkins container..."
docker rm -f jenkins || true

DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

echo "Restarting Jenkins..."
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $DOCKER_GID \
  jenkins-casc

echo "Jenkins restarted → http://localhost:8080"

# Auto open in WSL
if command -v wslview &> /dev/null; then
  wslview http://localhost:8080
fi
