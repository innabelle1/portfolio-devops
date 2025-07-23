from pathlib import Path

output_dir = Path("jenkins")

# plugins.txt
plugins_txt = """\
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
"""

# casc.yaml.template
with open("jenkins/casc.yaml.template", "w") as f:
    f.write("""
credentials:
  system:
    domainCredentials:
      - credentials:
          - string:
              scope: GLOBAL
              id: github-token
              description: "GitHub Token"
              secret: "${GITHUB_TOKEN}"

          - usernamePassword:
              scope: GLOBAL
              id: dockerhub-creds
              description: "DockerHub"
              username: "${DOCKERHUB_USERNAME}"
              password: "${DOCKERHUB_PASSWORD}"

          - amazonWebServices:
              scope: GLOBAL
              id: aws-ecr-creds
              description: "AWS Access Key"
              accessKey: "${AWS_ACCESS_KEY_ID}"
              secretKey: "${AWS_SECRET_ACCESS_KEY}"

jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: admin
          password: admin123
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
""")

# Dockerfile
dockerfile = """\
FROM jenkins/jenkins:lts

USER root
RUN apt-get update && \\
    apt-get install -y curl unzip gnupg awscli gettext && \\
    curl -fsSL https://get.docker.com | sh && \\
    usermod -aG docker jenkins

# Copy plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Casc config with envsubst
COPY casc.yaml.template /usr/share/jenkins/ref/casc.yaml.template
RUN envsubst < /usr/share/jenkins/ref/casc.yaml.template > /usr/share/jenkins/ref/jenkins.yaml

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml
USER jenkins
"""

# run-jenkins1.sh
run_script = """\
#!/bin/bash
set -e

cd "$(dirname "$0")"

if [ ! -f .env.jenkins ]; then
  echo "[ERROR] .env.jenkins file not found"
  exit 1
fi

# .env.jenkins
export $(grep -v '^#' .env.jenkins | xargs)

echo "Delete previous container."
docker rm -f jenkins || true

echo "Build Jenkins..."
docker build -t jenkins-casc .

DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

echo "Run Jenkins: http://localhost:8080"
docker run -d \\
  --name jenkins \\
  --env-file .env.jenkins \\
  -p 8080:8080 \\
  -v jenkins_home:/var/jenkins_home \\
  -v /var/run/docker.sock:/var/run/docker.sock \\
  --group-add $DOCKER_GID \\
  jenkins-casc

# check docker & aws in Jenkins container
echo "Verifying tools inside Jenkins container..."

echo "- Docker CLI version:"
docker exec -it jenkins docker --version || echo "Docker not found!"

echo "- AWS CLI version:"
docker exec -it jenkins aws --version || echo "AWS CLI not found!"

sleep 10
echo "Login: admin  |  Password: admin123"

if command -v wslview &> /dev/null; then
  wslview http://localhost:8080
fi
"""

# create files
(output_dir / "plugins.txt").write_text(plugins_txt)
(output_dir / "plugins.txt").chmod(0o644)
#(output_dir / "casc.yaml.template").write_text(casc_yaml_template)
#(output_dir / "casc.yaml.template").chmod(0o644)
(output_dir / "Dockerfile").write_text(dockerfile)
(output_dir / "Dockerfile").chmod(0o644)
(output_dir / "run-jenkins1.sh").write_text(run_script)
(output_dir / "run-jenkins1.sh").chmod(0o755)

print("Everything is ready. Open folder cd myscripts and run script: ./run-jenkins1.sh")
