#!/bin/bash

# load .env file if exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "File .env not found."
  exit 1
fi

JENKINS_CLI="jenkins-cli.jar"

# ----- run job
echo "Take all jobs 'petclinic-'..."
jobs=$(java -jar "$JENKINS_CLI" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" list-jobs | grep '^petclinic-')

if [[ -z "$jobs" ]]; then
  echo "[WARN] No job petclinic-"
  exit 1
fi

echo "[INFO] Found $(echo "$jobs" | wc -l) job:"
echo "$jobs"
echo

for job in $jobs; do
  echo "[RUNNING] : $job ..."
  java -jar "$JENKINS_CLI" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" build "$job"
done

echo "[DONE] All jobs running."
