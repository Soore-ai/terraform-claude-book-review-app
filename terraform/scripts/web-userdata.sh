#!/bin/bash
set -e
exec > >(tee /var/log/userdata.log) 2>&1

echo "========== Web Tier Bootstrap Starting =========="
echo "Timestamp: $(date)"

# ------------------------------------------------------------------------------
# 1. System updates
# ------------------------------------------------------------------------------
apt-get update -y
apt-get upgrade -y

# ------------------------------------------------------------------------------
# 2. Install Node.js 18
# ------------------------------------------------------------------------------
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# ------------------------------------------------------------------------------
# 3. Install Nginx and Git
# ------------------------------------------------------------------------------
apt-get install -y nginx git

# ------------------------------------------------------------------------------
# 4. Clone the application repository
# ------------------------------------------------------------------------------
git clone https://github.com/pravinmishraaws/book-review-app.git /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# ------------------------------------------------------------------------------
# 5. Build the frontend
# ------------------------------------------------------------------------------
cd /home/ubuntu/app/frontend

# Patch api.js to use ?? instead of || so empty NEXT_PUBLIC_API_URL is not
# overridden by the localhost fallback (empty string is falsy in JS).
sed -i 's#process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001"#process.env.NEXT_PUBLIC_API_URL ?? ""#g' /home/ubuntu/app/frontend/src/services/api.js

# API calls use relative URLs (e.g. /api/books) so the browser sends them
# to the same host. Nginx then proxies /api requests to the Internal ALB.
cat > .env <<EOF
NEXT_PUBLIC_API_URL=
EOF

npm install
npm run build
chown -R ubuntu:ubuntu /home/ubuntu/app/frontend

# ------------------------------------------------------------------------------
# 6. Install PM2 and start the frontend
# ------------------------------------------------------------------------------
npm install -g pm2
sudo -u ubuntu pm2 start npm --name "frontend" -- start
sudo -u ubuntu pm2 save

# Set PM2 to start on boot
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo -u ubuntu pm2 save

# ------------------------------------------------------------------------------
# 7. Configure Nginx as reverse proxy
# ------------------------------------------------------------------------------
cat > /etc/nginx/sites-available/default <<NGINX
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    # Proxy API requests to the Internal ALB (backend)
    location /api {
        proxy_pass http://${internal_alb_dns}:3001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Everything else goes to the Next.js frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINX

# Test and restart Nginx
nginx -t
systemctl restart nginx
systemctl enable nginx

echo "========== Web Tier Bootstrap Complete =========="
echo "Frontend running on port 3000, Nginx proxying on port 80"