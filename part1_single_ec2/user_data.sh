#!/bin/bash
# ==============================================================================
# Cloud-Init / User Data: Single EC2 Full-Stack Bootstrap
# Author: Rahul Motvani
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y git curl python3 python3-pip python3-venv nginx

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Clone project repository
mkdir -p /opt/app
git clone https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment.git /opt/app || true
chown -R ubuntu:ubuntu /opt/app

# 1. Setup Flask Backend
cd /opt/app/backend
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

cat << 'SERVICE_BE' > /etc/systemd/system/flask-backend.service
[Unit]
Description=Gunicorn serving Flask Backend API
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app/backend
Environment="PATH=/opt/app/backend/venv/bin:/usr/bin"
Environment="PORT=5000"
ExecStart=/opt/app/backend/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE_BE

# 2. Setup Express Frontend
cd /opt/app/frontend
npm install --production

cat << 'SERVICE_FE' > /etc/systemd/system/express-frontend.service
[Unit]
Description=Node.js Express Frontend Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app/frontend
Environment="NODE_ENV=production"
Environment="PORT=3000"
Environment="BACKEND_URL=http://127.0.0.1:5000"
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE_FE

systemctl daemon-reload
systemctl enable --now flask-backend
systemctl enable --now express-frontend

# 3. Setup Nginx Reverse Proxy
cat << 'NGINX_CONF' > /etc/nginx/sites-available/fullstack.conf
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

    location /api/ {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://127.0.0.1:5000;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/fullstack.conf /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
