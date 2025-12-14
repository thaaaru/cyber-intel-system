#!/bin/bash

#############################################################################
# Cyber Security Intelligence System - Automated Deployment Script
#
# Usage: sudo ./deploy.sh
#        sudo bash deploy.sh
#        curl ... | sudo bash
#        sudo bash -c "$(curl -fsSL <url>)"
#
# This script automates the complete setup on your server
# Works from ANY directory - auto-detects source location
#############################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/opt/cyber-intel"
PYTHON_VERSION="3.8"
SERVICE_NAME="cyber-intel"

# Auto-detect script location (works from any directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"  # Source files are in same directory as this script

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

ask_yes_no() {
    local prompt="$1"
    local default="$2"

    if [ "$default" = "y" ]; then
        echo -ne "${YELLOW}$prompt (Y/n): ${NC}"
    else
        echo -ne "${YELLOW}$prompt (y/N): ${NC}"
    fi

    read -r response
    if [ -z "$response" ]; then
        response="$default"
    fi

    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        return 0
    else
        return 1
    fi
}

#############################################################################
# Pre-deployment Checks
#############################################################################

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must run as root. Use: sudo ./deploy.sh"
    fi
    print_step "Running as root"
}

check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        print_error "Cannot detect OS"
    fi

    if grep -q "Ubuntu\|Debian" /etc/os-release; then
        print_step "Running on Ubuntu/Debian"
    else
        print_warning "This script is optimized for Ubuntu/Debian. Other OS may work but unsupported."
        if ! ask_yes_no "Continue anyway?" "n"; then
            exit 1
        fi
    fi
}

check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 not found. Install with: apt-get install python3 python3-pip python3-venv"
    fi

    python_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
    print_step "Python $python_version found"
}

check_disk_space() {
    available=$(df /opt 2>/dev/null | tail -1 | awk '{print $4}')
    if [ "$available" -lt 100000 ]; then
        print_warning "Less than 100MB available in /opt"
        if ! ask_yes_no "Continue anyway?" "n"; then
            exit 1
        fi
    fi
    print_step "Sufficient disk space available"
}

#############################################################################
# Installation Steps
#############################################################################

create_project_structure() {
    print_header "Creating Project Structure"

    mkdir -p "$PROJECT_DIR"/{data,templates,static,backups}
    print_step "Created directories"

    # Create .gitignore if needed
    cat > "$PROJECT_DIR/.gitignore" << 'EOF'
.env
*.pyc
__pycache__/
venv/
data/security.db
data/security.db.backup
.DS_Store
*.log
EOF
    print_step "Created .gitignore"
}

install_system_packages() {
    print_header "Installing System Packages"

    print_info "Updating package manager..."
    apt-get update -qq

    packages="python3-pip python3-venv build-essential libssl-dev libffi-dev python3-dev"

    print_info "Installing required packages..."
    for package in $packages; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            apt-get install -y -qq "$package" || print_error "Failed to install $package"
        fi
    done

    print_step "System packages installed"
}

setup_python_environment() {
    print_header "Setting Up Python Environment"

    if [ -d "$PROJECT_DIR/venv" ]; then
        print_warning "Virtual environment already exists"
        if ask_yes_no "Recreate it?" "n"; then
            rm -rf "$PROJECT_DIR/venv"
        else
            print_step "Using existing virtual environment"
            return 0
        fi
    fi

    cd "$PROJECT_DIR"
    print_info "Creating virtual environment..."
    python3 -m venv venv

    print_info "Upgrading pip..."
    ./venv/bin/pip install --upgrade pip setuptools wheel -q

    print_step "Virtual environment created and configured"
}

copy_application_files() {
    print_header "Copying Application Files"

    # Check if files exist in source directory
    if [ ! -f "$SOURCE_DIR/app.py" ]; then
        print_error "Application files not found in source directory: $SOURCE_DIR"
    fi

    print_info "Source directory: $SOURCE_DIR"
    print_info "Target directory: $PROJECT_DIR"

    # Copy Python files
    [ -f "$SOURCE_DIR/app.py" ] && cp "$SOURCE_DIR/app.py" "$PROJECT_DIR/" && print_step "Copied app.py"
    [ -f "$SOURCE_DIR/scraper.py" ] && cp "$SOURCE_DIR/scraper.py" "$PROJECT_DIR/" && print_step "Copied scraper.py"
    [ -f "$SOURCE_DIR/whatsapp_sender.py" ] && cp "$SOURCE_DIR/whatsapp_sender.py" "$PROJECT_DIR/" && print_step "Copied whatsapp_sender.py"
    [ -f "$SOURCE_DIR/scheduler.py" ] && cp "$SOURCE_DIR/scheduler.py" "$PROJECT_DIR/" && print_step "Copied scheduler.py"
    [ -f "$SOURCE_DIR/database.py" ] && cp "$SOURCE_DIR/database.py" "$PROJECT_DIR/" && print_step "Copied database.py"

    # Copy configuration files
    [ -f "$SOURCE_DIR/requirements.txt" ] && cp "$SOURCE_DIR/requirements.txt" "$PROJECT_DIR/" && print_step "Copied requirements.txt"

    # Copy service file
    [ -f "$SOURCE_DIR/cyber-intel.service" ] && cp "$SOURCE_DIR/cyber-intel.service" "$PROJECT_DIR/" && print_step "Copied systemd service file"

    # Copy frontend files
    [ -d "$SOURCE_DIR/templates" ] && cp -r "$SOURCE_DIR/templates"/* "$PROJECT_DIR/templates/" 2>/dev/null && print_step "Copied templates"
    [ -d "$SOURCE_DIR/static" ] && cp -r "$SOURCE_DIR/static"/* "$PROJECT_DIR/static/" 2>/dev/null && print_step "Copied static files"

    # Copy documentation
    [ -d "$SOURCE_DIR" ] && find "$SOURCE_DIR" -maxdepth 1 -name "*.md" -exec cp {} "$PROJECT_DIR/" \; 2>/dev/null && print_step "Copied documentation"

    # Verify key files exist in target
    if [ ! -f "$PROJECT_DIR/app.py" ]; then
        print_error "Failed to copy application files to $PROJECT_DIR"
    fi

    print_step "All application files copied successfully"
}

install_python_packages() {
    print_header "Installing Python Packages"

    cd "$PROJECT_DIR"
    print_info "Installing packages from requirements.txt..."

    ./venv/bin/pip install -r requirements.txt -q || print_error "Failed to install Python packages"

    print_step "Python packages installed"

    # Verify key packages
    print_info "Verifying installations..."
    ./venv/bin/pip list | grep -E "Flask|SQLAlchemy|twilio" || print_warning "Some packages may not be properly installed"
}

initialize_database() {
    print_header "Initializing Database"

    cd "$PROJECT_DIR"

    if [ -f "data/security.db" ]; then
        print_warning "Database already exists"
        if ask_yes_no "Reinitialize (will erase data)?" "n"; then
            rm -f data/security.db
        else
            print_step "Using existing database"
            return 0
        fi
    fi

    print_info "Creating database schema..."
    ./venv/bin/python3 << 'PYTHON_EOF'
import sys
sys.path.insert(0, '/opt/cyber-intel')
from app import app, db
with app.app_context():
    db.create_all()
print("✓ Database initialized successfully")
PYTHON_EOF

    print_step "Database initialized"
}

setup_environment_file() {
    print_header "Setting Up Environment Configuration"

    if [ -f "$PROJECT_DIR/.env" ]; then
        print_warning ".env file already exists"
        if ask_yes_no "Overwrite?" "n"; then
            rm -f "$PROJECT_DIR/.env"
        else
            print_step "Using existing .env file"
            return 0
        fi
    fi

    print_info "Creating .env file template..."

    cat > "$PROJECT_DIR/.env" << 'EOF'
# Twilio Configuration - Get these from https://www.twilio.com/console
TWILIO_ACCOUNT_SID=YOUR_ACCOUNT_SID_HERE
TWILIO_AUTH_TOKEN=YOUR_AUTH_TOKEN_HERE
TWILIO_WHATSAPP_NUMBER=+14155552671
RECIPIENT_WHATSAPP_NUMBER=+1234567890

# Server Configuration
FLASK_ENV=production
DEBUG=False
EOF

    chmod 600 "$PROJECT_DIR/.env"
    print_step "Created .env file"

    print_warning "⚠️  IMPORTANT: Edit .env with your Twilio credentials:"
    echo -e "${YELLOW}   nano /opt/cyber-intel/.env${NC}"
}

setup_systemd_service() {
    print_header "Setting Up Systemd Service"

    # Copy and install service file
    cp "$PROJECT_DIR/cyber-intel.service" /etc/systemd/system/

    # Reload systemd daemon
    systemctl daemon-reload
    print_step "Copied systemd service file"

    # Enable service
    systemctl enable cyber-intel
    print_step "Enabled service for auto-start"

    # Create log rotation config
    cat > /etc/logrotate.d/cyber-intel << 'EOF'
/var/log/cyber-intel.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
    missingok
}
EOF
    print_step "Configured log rotation"
}

start_service() {
    print_header "Starting Service"

    print_info "Starting cyber-intel service..."
    systemctl start cyber-intel

    # Wait for service to start
    sleep 2

    if systemctl is-active --quiet cyber-intel; then
        print_step "Service started successfully"
    else
        print_error "Failed to start service. Check: sudo journalctl -u cyber-intel -n 20"
    fi
}

verify_installation() {
    print_header "Verifying Installation"

    # Check service status
    if systemctl is-active --quiet cyber-intel; then
        print_step "Service is running"
    else
        print_error "Service is not running"
    fi

    # Check port
    if netstat -tlnp 2>/dev/null | grep -q "5000"; then
        print_step "Port 5000 is listening"
    else
        print_warning "Port 5000 is not listening yet (may take a moment)"
    fi

    # Check database
    if [ -f "$PROJECT_DIR/data/security.db" ]; then
        print_step "Database file exists"
    else
        print_error "Database file not found"
    fi

    # Check .env
    if [ -f "$PROJECT_DIR/.env" ]; then
        print_step ".env file exists"
    else
        print_error ".env file not found"
    fi
}

#############################################################################
# Main Deployment Flow
#############################################################################

main() {
    print_header "Cyber Security Intelligence System - Automated Deployment"

    # Show where script is running from
    print_info "Script running from: $(pwd)"
    print_info "Source files location: $SOURCE_DIR"
    print_info "Deployment target: $PROJECT_DIR"
    echo ""

    echo -e "This script will:"
    echo -e "  1. Install system dependencies"
    echo -e "  2. Set up Python virtual environment"
    echo -e "  3. Copy application files from $SOURCE_DIR"
    echo -e "  4. Install Python packages"
    echo -e "  5. Initialize database"
    echo -e "  6. Configure Twilio credentials"
    echo -e "  7. Set up systemd service"
    echo -e "  8. Start the service"
    echo ""

    if ! ask_yes_no "Ready to deploy?" "y"; then
        echo "Deployment cancelled."
        exit 0
    fi

    # Pre-deployment checks
    check_root
    check_ubuntu
    check_python
    check_disk_space

    # Main installation
    create_project_structure
    install_system_packages
    setup_python_environment
    copy_application_files
    install_python_packages
    initialize_database
    setup_environment_file
    setup_systemd_service
    start_service
    verify_installation

    # Final summary
    print_header "✅ DEPLOYMENT COMPLETE!"

    cat << EOF
Your Cyber Security Intelligence System is now running!

📋 NEXT STEPS:

1️⃣  Edit Twilio Credentials:
   sudo nano /opt/cyber-intel/.env

   Add your:
   - TWILIO_ACCOUNT_SID
   - TWILIO_AUTH_TOKEN
   - TWILIO_WHATSAPP_NUMBER
   - RECIPIENT_WHATSAPP_NUMBER

2️⃣  Restart Service (after editing .env):
   sudo systemctl restart cyber-intel

3️⃣  Access Dashboard:
   Open browser: http://localhost:5000

   Or from another machine:
   http://$(hostname -I | awk '{print $1}'):5000

4️⃣  Verify Everything:
   - Check logs: sudo journalctl -u cyber-intel -f
   - Test API: curl http://localhost:5000/api/stats
   - Trigger scrape: curl http://localhost:5000/api/refresh

5️⃣  Test WhatsApp Alert:
   Click "🔄 Refresh News" on dashboard
   Then "Send Alert" on any news item

   Should receive WhatsApp message in <5 seconds

📊 IMPORTANT INFORMATION:

Service Status: sudo systemctl status cyber-intel
View Logs: sudo journalctl -u cyber-intel -f
Stop Service: sudo systemctl stop cyber-intel
Restart Service: sudo systemctl restart cyber-intel

Database Location: /opt/cyber-intel/data/security.db
Configuration: /opt/cyber-intel/.env
Backup Database: cp /opt/cyber-intel/data/security.db /opt/cyber-intel/data/security.db.backup

📚 DOCUMENTATION:
- Quick Start: /opt/cyber-intel/QUICK_START.md
- Full Guide: /opt/cyber-intel/DEPLOYMENT.md
- Checklist: /opt/cyber-intel/DEPLOYMENT_CHECKLIST.md

⏰ AUTOMATIC OPERATIONS:
✓ News Scraping: Every 2 hours
✓ WhatsApp Digest: Daily at 9:00 AM
✓ Auto-start: On server reboot

🔒 Security:
- Credentials stored in .env (excluded from git)
- Database is local (no remote access)
- Communication to Twilio is encrypted (HTTPS)

Happy threat hunting! 🚀🔒

EOF
}

#############################################################################
# Error Handling
#############################################################################

trap 'print_error "Deployment failed. Check logs above for details."' ERR

#############################################################################
# Run Main
#############################################################################

main "$@"
