#!/bin/bash

set -e

# === Configuration ===
ALB_DNS_NAME=${var.private_alb_dns_name}
CONTAINER_NAME="nginx-reverse-proxy"

echo "=== Creating NGINX configuration for reverse proxy ==="
cat <<EOF > nginx.conf
events {}

http {
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://${ALB_DNS_NAME};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

echo "=== Running NGINX container as reverse proxy ==="
docker run -d \
  --name ${CONTAINER_NAME} \
  -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:latest

echo "=== Reverse proxy is up and running! ==="
echo "Requests to this EC2 instance on port 80 will be forwarded to: http://${ALB_DNS_NAME}"
