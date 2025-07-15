#!/bin/bash
set -e

# plugins.txt
cat <<EOF > plugins.txt
git
credentials
plain-credentials
credentials-binding
aws-credentials
ssh-credentials
docker-commons
workflow-aggregator
blueocean
docker-plugin
amazon-ecr
kubernetes
pipeline-stage-view
workflow-multibranch
pipeline-github-lib
cloudbees-folder
configuration-as-code
EOF

# casc.yaml 
cat <<EOF > casc.yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - string:
              scope: GLOBAL
              id: github-token
              description: "GitHub Token"
              secret: "example"

          - usernamePassword:
              scope: GLOBAL
              id: dockerhub-creds
              description: "DockerHub"
              username: "name"
              password: "example"

          - usernamePassword:
              scope: GLOBAL
              id: aws-access
              description: "AWS Access Key"
              username: "example"
              password: "example"

jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: example
          password: example
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
EOF


# Dockerfile for Jenkins w/ plugins
cat <<EOF > Dockerfile
FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y curl

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# JCasC config
COPY casc.yaml /usr/share/jenkins/ref/jenkins.yaml

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml

USER jenkins
EOF

# Build & run Jenkins
cat <<'EOF' > run-jenkins1.sh

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
EOF

# Access
chmod +x run-jenkins.sh
chmod 644 Dockerfile plugins.txt casc.yaml

echo "Everything is ready. Open folder cd myscripts and run scripts  ./run-jenkins.sh"
