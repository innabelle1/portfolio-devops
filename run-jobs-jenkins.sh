#!/bin/bash

#  .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "[ERROR] File .env not found."
  exit 1
fi

if [[ -z "$JENKINS_URL" || -z "$JENKINS_USER" || -z "$JENKINS_TOKEN" ]]; then
  echo "[ERROR] JENKINS_URL, JENKINS_USER или JENKINS_TOKEN не заданы в .env"
  exit 1
fi

JENKINS_CLI="jenkins-cli.jar"

# check jenkins-cli.jar
if [ ! -f "$JENKINS_CLI" ]; then
  echo "[INFO] dowload Jenkins CLI..."
  curl -sSL "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -o "$JENKINS_CLI"
fi

# list of jobs petclinic-*
echo "[INFO] List of  Jenkins jobs 'petclinic-*'..."
jobs=$(java -jar "$JENKINS_CLI" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" list-jobs | grep '^petclinic-')

if [[ -z "$jobs" ]]; then
  echo "[WARN] No job with 'petclinic-'"
  exit 1
fi

echo "[INFO] Found $(echo "$jobs" | wc -l) jobs:"
echo "$jobs"
echo

# run all jobs
for job in $jobs; do
  echo "[RUNNING] $job ..."
  java -jar "$JENKINS_CLI" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" build "$job"
done

echo "[DONE] All jobs running."
