#!/bin/bash

# EpicBook Deployment Script
# This script is called from cloud-init to set up the EpicBook application

set -e  # Exit on any error

# Log file
LOG_FILE="/var/log/epicbook-deployment.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "$(date): Starting EpicBook deployment..."

# Environment variables (passed from cloud-init/templatefile)
MYSQL_HOST="${mysql_host}"
MYSQL_USERNAME="${mysql_username}"
MYSQL_PASSWORD="${mysql_password}"
REPO_URL="${repo_url}"
BRANCH="${branch}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Wait for MySQL to be accessible
wait_for_mysql() {
    log "Waiting for MySQL to be ready at $MYSQL_HOST..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if mysql -h "$MYSQL_HOST" -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "SELECT 1;" 2>/dev/null; then
            log "MySQL is ready!"
            return 0
        fi

        warn "MySQL not ready yet (attempt $attempt/$max_attempts). Retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done

    error "MySQL failed to become ready after $max_attempts attempts"
    return 1
}

# Clone and setup EpicBook application
setup_application() {
    log "Setting up EpicBook application..."

    # Clone repository
    if [ ! -d "/opt/epicbook" ]; then
        log "Cloning EpicBook repository from $REPO_URL (branch: $BRANCH)"
        git clone -b "$BRANCH" "$REPO_URL" /opt/epicbook
    else
        log "EpicBook directory already exists, pulling latest changes"
        cd /opt/epicbook
        git pull origin "$BRANCH"
    fi

    cd /opt/epicbook

    # Install root dependencies
    log "Installing root dependencies..."
    npm install

    # Create environment file for backend
    log "Creating environment configuration..."
    cat > .env << EOF
DB_HOST=$MYSQL_HOST
DB_USER=$MYSQL_USERNAME
DB_PASSWORD=$MYSQL_PASSWORD
DB_NAME=epicbook
DB_PORT=3306
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-in-production
EOF

    # Setup frontend
    log "Setting up frontend..."
    cd frontend
    npm install

    log "Building frontend..."
    npm run build

    # Setup backend
    log "Setting up backend..."
    cd ../backend
    npm install

    # Create uploads directory if needed
    mkdir -p uploads
}

# Configure nginx
setup_nginx() {
    log "Configuring nginx..."

    # Create nginx configuration
    cat > /etc/nginx/sites-available/epicbook << 'EOF'
server {
    listen 80;
    server_name _;
    root /opt/epicbook/frontend/build;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # SPA routes - serve index.html for all non-file routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }

    # Static files
    location /static/ {
        alias /opt/epicbook/frontend/build/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

    # Enable site
    ln -sf /etc/nginx/sites-available/epicbook /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default

    # Test nginx configuration
    log "Testing nginx configuration..."
    nginx -t

    log "Restarting nginx..."
    systemctl restart nginx
    systemctl enable nginx
}

# Setup systemd service for backend
setup_systemd_service() {
    log "Setting up systemd service for EpicBook backend..."

    cat > /etc/systemd/system/epicbook.service << EOF
[Unit]
Description=EpicBook Backend Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/epicbook/backend
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=epicbook

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes

Environment=NODE_ENV=production
Environment=PATH=/usr/bin:/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable epicbook.service
}

# Initialize database
initialize_database() {
    log "Initializing database..."

    cd /opt/epicbook/backend

    # Wait for MySQL to be ready
    wait_for_mysql

    # Run database migrations
    log "Running database migrations..."
    if command -v npx &> /dev/null; then
        npx sequelize-cli db:migrate
    else
        npm install -g sequelize-cli
        npx sequelize-cli db:migrate
    fi

    # Run database seeds
    log "Running database seeds..."
    if command -v npx &> /dev/null; then
        npx sequelize-cli db:seed:all
    else
        npx sequelize-cli db:seed:all
    fi

    log "Database initialization completed"
}

# Start application services
start_services() {
    log "Starting EpicBook backend service..."
    systemctl start epicbook.service

    # Wait a moment for the service to start
    sleep 5

    # Check if service is running
    if systemctl is-active --quiet epicbook.service; then
        log "EpicBook backend service is running successfully"
    else
        error "EpicBook backend service failed to start"
        journalctl -u epicbook.service -n 50 --no-pager
        exit 1
    fi
}

# Perform health check
health_check() {
    log "Performing health check..."

    local max_attempts=10
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
            log "Backend health check passed!"
            break
        fi

        if [ $attempt -eq $max_attempts ]; then
            warn "Backend health check failed after $max_attempts attempts"
            return 1
        fi

        warn "Backend not ready yet (attempt $attempt/$max_attempts). Retrying in 5 seconds..."
        sleep 5
        ((attempt++))
    done

    # Check nginx
    if systemctl is-active --quiet nginx; then
        log "Nginx is running successfully"
    else
        error "Nginx is not running"
        return 1
    fi

    return 0
}

# Main deployment function
main() {
    log "Starting EpicBook deployment process..."

    # Update system packages
    log "Updating system packages..."
    apt-get update
    apt-get upgrade -y

    # Install additional required packages
    log "Installing additional packages..."
    apt-get install -y build-essential python3

    setup_application
    setup_nginx
    setup_systemd_service
    initialize_database
    start_services
    health_check

    log "EpicBook deployment completed successfully!"
    log "Application should be accessible at: http://$(curl -s ifconfig.me)"
    log "Backend API: http://localhost:3000/api"
    log "Check deployment logs: tail -f $LOG_FILE"
}

# Run main function
main "$@"
