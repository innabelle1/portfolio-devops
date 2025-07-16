#!/bin/bash
set -e

echo "System update..."
sudo apt update && sudo apt upgrade -y

echo "Instal dependencies..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "Add  GPG-key Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Add  Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Update  APT, install Docker & Docker Compose..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Add user to docker group (relogin)..."
sudo usermod -aG docker $USER

echo "Check Docker..."
docker --version
docker compose version
