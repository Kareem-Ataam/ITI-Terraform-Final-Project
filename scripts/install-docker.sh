#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
sudo yum update -y

sudo yum install docker -y

sudo systemctl enable --now docker

sudo usermod -aG docker $USER

echo "=== Checking Docker version ==="
docker --version

