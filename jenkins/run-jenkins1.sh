#!/bin/bash
set -e

echo "Delete previous container."
docker rm -f jenkins || true

echo "Build Jenkins..."
docker build -t jenkins-casc .

echo "Run Jenkins  http://localhost:8080"
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-casc

sleep 15
echo "Admin: admin"
echo "Password: admin123"

# Open in browser (WSL2)
if command -v wslview &> /dev/null; then
  wslview http://localhost:8080
fi
