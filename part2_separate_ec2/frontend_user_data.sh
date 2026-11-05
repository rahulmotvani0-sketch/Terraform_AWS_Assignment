#!/bin/bash
# ==============================================================================
# Cloud-Init / User Data: Instance B (Frontend Express Service)
# Author: Rahul Motvani
# ==============================================================================
set -euo pipefail

BACKEND_TARGET_IP="${backend_private_ip}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git curl nginx

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

mkdir -p /opt/app
git clone https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment.git /opt/app || true
chown -R ubuntu:ubuntu /opt/app

cd /opt/app/frontend
npm install --production

cat << SERVICE_EOF > /etc/systemd/system/express-frontend.service
[Unit]
Description=Express Frontend on Instance B
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app/frontend
Environment="NODE_ENV=production"
Environment="PORT=3000"
Environment="BACKEND_URL=http://$${BACKEND_TARGET_IP}:5000"
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable --now express-frontend

# Nginx Reverse Proxy
cat << 'NGINX_EOF' > /etc/nginx/sites-available/frontend.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX_EOF

ln -sf /etc/nginx/sites-available/frontend.conf /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
