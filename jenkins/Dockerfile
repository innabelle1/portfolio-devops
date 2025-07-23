FROM jenkins/jenkins:lts

USER root
RUN apt-get update && \
    apt-get install -y curl unzip gnupg awscli && \
    curl -fsSL https://get.docker.com | sh && \
    usermod -aG docker jenkins

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# JCasC config
COPY casc.yaml /usr/share/jenkins/ref/jenkins.yaml

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/jenkins.yaml

USER jenkins
