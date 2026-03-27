#!/bin/bash
set -e
exec > >(tee /var/log/userdata.log) 2>&1

echo "========== App Tier Bootstrap Starting =========="
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
# 3. Install Git and MySQL client (for testing DB connectivity)
# ------------------------------------------------------------------------------
apt-get install -y git mysql-client

# ------------------------------------------------------------------------------
# 4. Clone the application repository
# ------------------------------------------------------------------------------
git clone https://github.com/pravinmishraaws/book-review-app.git /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# ------------------------------------------------------------------------------
# 5. Configure the backend
# ------------------------------------------------------------------------------
cd /home/ubuntu/app/backend

cat > .env <<EOF
PORT=3001
DB_HOST=${db_host}
DB_USER=${db_username}
DB_PASS=${db_password}
DB_NAME=book_review_db
DB_DIALECT=mysql
JWT_SECRET=${jwt_secret}
ALLOWED_ORIGINS=${allowed_origins}
EOF

chown ubuntu:ubuntu .env
chmod 600 .env

# ------------------------------------------------------------------------------
# 6. Install dependencies
# ------------------------------------------------------------------------------
npm install

# ------------------------------------------------------------------------------
# 7. Start the backend with PM2
# ------------------------------------------------------------------------------
npm install -g pm2
sudo -u ubuntu pm2 start src/server.js --name "book-review-backend"
sudo -u ubuntu pm2 save

# Set PM2 to start on boot
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo -u ubuntu pm2 save

echo "========== App Tier Bootstrap Complete =========="
echo "Backend running on port 3001"
