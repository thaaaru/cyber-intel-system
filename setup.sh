#!/bin/bash

# Cyber Security Intelligence System - Setup Script
# This script automates the deployment on your server

set -e

echo "================================"
echo "Cyber Security Intelligence"
echo "Setup & Deployment"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   echo "❌ Please run as root: sudo ./setup.sh"
   exit 1
fi

# Create project directory
echo "📁 Creating project directory..."
mkdir -p /opt/cyber-intel
cd /opt/cyber-intel

# Create data directory
mkdir -p data

# Create virtual environment
echo "🐍 Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt > /dev/null 2>&1

# Initialize database
echo "🗄️  Initializing database..."
python3 << EOF
from app import app, db
with app.app_context():
    db.create_all()
print("✅ Database initialized successfully!")
EOF

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your Twilio credentials:"
    echo "   nano /opt/cyber-intel/.env"
else
    echo "✅ .env file already exists"
fi

# Set up systemd service
echo "🔧 Setting up systemd service..."
cp cyber-intel.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable cyber-intel

# Create log rotation config
echo "📋 Setting up log rotation..."
cat > /etc/logrotate.d/cyber-intel << 'EOF'
/var/log/cyber-intel.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
EOF

echo ""
echo "================================"
echo "✅ Setup Complete!"
echo "================================"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Edit your Twilio credentials:"
echo "   nano /opt/cyber-intel/.env"
echo ""
echo "2. Start the service:"
echo "   systemctl start cyber-intel"
echo ""
echo "3. Check status:"
echo "   systemctl status cyber-intel"
echo ""
echo "4. View logs:"
echo "   journalctl -u cyber-intel -f"
echo ""
echo "5. Access dashboard:"
echo "   http://your-server-ip:5000"
echo ""
echo "📖 Full guide: cat /opt/cyber-intel/DEPLOYMENT.md"
echo ""
