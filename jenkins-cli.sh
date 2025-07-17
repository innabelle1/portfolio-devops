#!/bin/bash

# host IP 
if grep -qi microsoft /proc/version; then
    echo "Running in WSL. Detecting Windows host IP..."
    HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
else
    HOST_IP="localhost"
fi

JENKINS_URL="http://${HOST_IP}:8080"
CLI_JAR="jenkins-cli.jar"

# check .netrc
if [ ! -f ~/.netrc ]; then
  echo "File ~/.netrc not found. Create it with login & password."
  exit 1
fi

# download jenkins-cli.jar
if [ ! -f "$CLI_JAR" ]; then
  echo "Dowload Jenkins CLI..."
  wget -q -O "$CLI_JAR" "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
  if [ $? -ne 0 ]; then
    echo "Cant dowload jenkins-cli.jar"
    exit 1
  fi
  echo "Jenkins CLI is ready."
fi

# check Jenkins status
echo "Check Jenkins status $JENKINS_URL ..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL/login")

if [ "$STATUS" != "200" ]; then
  echo "Jenkins isnt access (HTTP $STATUS). Check  URL & run container in docker."
  exit 1
fi

LOGIN=$(awk '/^machine localhost/ {getline; print $2}' ~/.netrc)
PASS=$(awk '/^machine localhost/ {getline; getline; print $2}' ~/.netrc)

if [ -z "$LOGIN" ] || [ -z "$PASS" ]; then
  echo "Cant find login/password from ~/.netrc"
  exit 1
fi

# run Jenkins CLI 
java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth "$LOGIN:$PASS" "$@"
