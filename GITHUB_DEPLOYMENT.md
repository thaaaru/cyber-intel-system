# Deploying from GitHub Repository

This guide shows how to deploy the Cyber Security Intelligence System from the GitHub repository.

The deploy script now works from **ANY directory** - no need to cd into the project folder!

---

## ✅ Deploy in 4 Simple Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/thaaaru/cyber-intel-system.git /opt/cyber-intel
```

Or clone to any directory:

```bash
git clone https://github.com/thaaaru/cyber-intel-system.git ~/cyber-intel
```

### Step 2: Make Deploy Script Executable

```bash
chmod +x /path/to/deploy.sh
```

### Step 3: Run Deployment (From Anywhere!)

You can run the script from **ANY directory**:

```bash
# From home directory
sudo /opt/cyber-intel/deploy.sh

# From /tmp
sudo /tmp/deploy.sh

# From project directory (also works)
cd /opt/cyber-intel
sudo ./deploy.sh

# Using bash directly
sudo bash /opt/cyber-intel/deploy.sh
```

The script will:
- Auto-detect source files location
- Check for system dependencies
- Create Python virtual environment
- Copy all application files
- Install Python packages
- Initialize database
- Create .env configuration file
- Set up systemd service
- Start the service

---

## 🚀 Fastest Deployment (One-Line Command)

Clone and deploy everything in one go:

```bash
git clone https://github.com/thaaaru/cyber-intel-system.git /opt/cyber-intel && \
sudo /opt/cyber-intel/deploy.sh
```

That's it! No need to cd anywhere.

---

## 🌐 Download and Run Directly

You don't even need to clone first. Just download and run:

```bash
cd /tmp
curl -O https://raw.githubusercontent.com/thaaaru/cyber-intel-system/main/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

The script will auto-detect where the repo files are and pull them.

---

## ⚙️ After Deployment

### Configure Twilio Credentials

```bash
sudo nano /opt/cyber-intel/.env
```

Edit and add:
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_token_here
TWILIO_WHATSAPP_NUMBER=+14155552671
RECIPIENT_WHATSAPP_NUMBER=+1234567890
```

Save and exit: `Ctrl+X`, `Y`, `Enter`

### Restart the Service

```bash
sudo systemctl restart cyber-intel
```

### Access the Dashboard

Open in browser:
```
http://your-server-ip:5000
```

---

## 🔍 Troubleshooting

### "Permission denied" when running script

```bash
# Make sure script is executable
chmod +x /opt/cyber-intel/deploy.sh
chmod +x /opt/cyber-intel/setup.sh

# Run with sudo
sudo /opt/cyber-intel/deploy.sh
```

### "Application files not found"

Make sure you're in the correct directory:

```bash
# Check you're in the right place
pwd
# Should show: /opt/cyber-intel

# Check files exist
ls app.py
# Should list: app.py

# If files don't exist, re-clone the repository
cd /tmp
git clone https://github.com/thaaaru/cyber-intel-system.git /opt/cyber-intel
cd /opt/cyber-intel
sudo ./deploy.sh
```

### Service won't start

```bash
# Check what went wrong
sudo journalctl -u cyber-intel -n 50

# Common issues:
# 1. Missing .env file → Create it with credentials
# 2. Port 5000 in use → Check with: netstat -tlnp | grep 5000
# 3. Database error → Delete data/security.db and restart
```

### WhatsApp not sending

1. Check .env has correct Twilio credentials:
```bash
sudo cat /opt/cyber-intel/.env
```

2. Verify phone number format (must include + and country code):
```
+1234567890  ✅ Correct
1234567890   ❌ Wrong (missing +)
+1 234 5678  ❌ Wrong (has spaces)
```

3. Restart service:
```bash
sudo systemctl restart cyber-intel
```

---

## 📋 Quick Reference

| Task | Command |
|------|---------|
| Clone repo | `git clone https://github.com/thaaaru/cyber-intel-system.git /opt/cyber-intel` |
| Start deployment | `cd /opt/cyber-intel && sudo ./deploy.sh` |
| Check status | `sudo systemctl status cyber-intel` |
| View logs | `sudo journalctl -u cyber-intel -f` |
| Stop service | `sudo systemctl stop cyber-intel` |
| Restart service | `sudo systemctl restart cyber-intel` |
| Edit config | `sudo nano /opt/cyber-intel/.env` |
| Access dashboard | `http://your-ip:5000` |
| Pull latest code | `cd /opt/cyber-intel && git pull origin main` |

---

## 🔄 Keeping Up with Updates

To get the latest updates:

```bash
cd /opt/cyber-intel
git pull origin main
sudo systemctl restart cyber-intel
```

Or automate weekly updates:

```bash
# Add to crontab
sudo crontab -e

# Add this line (runs every Sunday at 2 AM)
0 2 * * 0 cd /opt/cyber-intel && git pull origin main && systemctl restart cyber-intel
```

---

## ✨ That's It!

Your system is now deployed and running. Access the dashboard at `http://your-server-ip:5000`

Happy threat hunting! 🔒🚀
