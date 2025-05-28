#!/bin/bash

exec > >(tee /var/log/user-data.log) 2>&1
set -e

echo "=== USER DATA SCRIPT STARTED ==="

# Update packages
dnf update -y --allowerasing --skip-broken || echo "Update completed with warnings"

# Install dependencies
dnf install -y gcc gcc-c++ python3-devel git nginx python3 python3-pip curl unzip tar make --allowerasing

# Confirm tools
git --version
python3 --version
pip3 --version
nginx -v

# Create and activate Python virtual environment
echo "Creating virtual environment for backend..."
python3 -m venv /home/ec2-user/backend-venv
source /home/ec2-user/backend-venv/bin/activate

# Upgrade pip and install Python packages inside virtualenv
pip install --upgrade pip
pip install fastapi uvicorn pandas numpy nba-api scikit-learn joblib

# Install Deno
cd /opt
curl -fsSL https://deno.land/x/install/install.sh -o install_deno.sh
chmod +x install_deno.sh
DENO_INSTALL=/opt/deno ./install_deno.sh
echo 'export DENO_INSTALL=/opt/deno' >> /etc/profile
echo 'export PATH=$DENO_INSTALL/bin:$PATH' >> /etc/profile
export DENO_INSTALL=/opt/deno
export PATH=$DENO_INSTALL/bin:$PATH

# Verify Deno
deno --version || echo "❌ Deno failed to install"

# Clone project
git clone https://github.com/rodrigofbmm/TFG.git /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/app

# Copy ML models
mkdir -p /home/ec2-user/app/tfg_nba/back-part
cp /home/ec2-user/app/tfg_nba/modelo-definitivo/*.pkl /home/ec2-user/app/tfg_nba/back-part/ || echo "No .pkl files found"

# Create systemd service for backend
cat <<EOF > /etc/systemd/system/nba-backend.service
[Unit]
Description=NBA Backend API (FastAPI)
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/tfg_nba/back-part
Environment=PATH=/home/ec2-user/backend-venv/bin
ExecStart=/home/ec2-user/backend-venv/bin/uvicorn predict_api:app --host 0.0.0.0 --port 8008
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for frontend
cat <<EOF > /etc/systemd/system/nba-frontend.service
[Unit]
Description=NBA Frontend (Deno)
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app/tfg_nba/front-part
Environment=PATH=/opt/deno/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/opt/deno/bin/deno task start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable services
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable nba-backend.service
systemctl enable nba-frontend.service
systemctl start nba-backend.service
systemctl start nba-frontend.service

# Configure NGINX
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server {
        listen 80 default_server;
        server_name _;

        location /api/ {
            proxy_pass http://localhost:8008/;
        }

        location / {
            proxy_pass http://localhost:8000/;
        }
    }
}
EOF

# Start NGINX
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "=== USER DATA SCRIPT COMPLETED ==="
