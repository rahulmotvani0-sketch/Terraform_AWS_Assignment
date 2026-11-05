#!/bin/bash
# ==============================================================================
# Cloud-Init / User Data: Instance A (Backend Flask Service)
# Author: Rahul Motvani
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git python3 python3-pip python3-venv

mkdir -p /opt/app
git clone https://github.com/rahulmotvani0-sketch/Terraform_AWS_Assignment.git /opt/app || true
chown -R ubuntu:ubuntu /opt/app

cd /opt/app/backend
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

cat << 'SERVICE_EOF' > /etc/systemd/system/flask-backend.service
[Unit]
Description=Gunicorn serving Flask Backend API on Instance A
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
SERVICE_EOF

systemctl daemon-reload
systemctl enable --now flask-backend
