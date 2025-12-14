# Cyber Security Intelligence System - Deployment Guide

Complete step-by-step guide to deploy on your server: `root@68.183.176.66`

---

## Prerequisites

- Ubuntu/Debian Linux server
- Python 3.8+
- Root or sudo access
- Twilio account with WhatsApp enabled

---

## Step 1: Connect to Your Server

```bash
ssh root@68.183.176.66
```

---

## Step 2: Create Project Directory

```bash
mkdir -p /opt/cyber-intel
cd /opt/cyber-intel
```

---

## Step 3: Copy All Files to Server

From your local machine, copy the entire project:

```bash
scp -r /Users/tharaka/claude_space/mycti/cyber-intel-system/* root@68.183.176.66:/opt/cyber-intel/
```

Or manually create each file on the server using `nano` or `vi`:

```bash
# On server
nano app.py
# Paste contents of app.py
# Ctrl+X, Y, Enter to save
```

---

## Step 4: Set Up Python Virtual Environment

```bash
cd /opt/cyber-intel
python3 -m venv venv
source venv/bin/activate
```

---

## Step 5: Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

---

## Step 6: Configure Twilio (WhatsApp)

### 6.1 Sign up at Twilio

1. Go to https://www.twilio.com/console
2. Sign up or log in
3. Navigate to **Messaging → WhatsApp**
4. Click "**Try WhatsApp**"
5. Complete the opt-in (send "join" to their sandbox number)

### 6.2 Get Your Credentials

- **Account SID**: Copy from Twilio Console
- **Auth Token**: Copy from Twilio Console
- **Twilio WhatsApp Number**: Provided by Twilio (format: +1415...)
- **Your WhatsApp Number**: Your phone number where you'll receive alerts (format: +1234567890)

### 6.3 Create .env File

```bash
cat > /opt/cyber-intel/.env << EOF
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_WHATSAPP_NUMBER=+14155552671
RECIPIENT_WHATSAPP_NUMBER=+1234567890

FLASK_ENV=production
DEBUG=False
EOF
```

Replace with your actual Twilio credentials.

---

## Step 7: Initialize Database

```bash
cd /opt/cyber-intel
source venv/bin/activate
python3 << EOF
from app import app, db
with app.app_context():
    db.create_all()
print("Database initialized successfully!")
EOF
```

---

## Step 8: Test the Application

```bash
# Start the Flask app
cd /opt/cyber-intel
source venv/bin/activate
python3 app.py
```

You should see:
```
* Running on http://0.0.0.0:5000
```

**Test in another terminal:**
```bash
curl http://localhost:5000/
curl http://localhost:5000/api/stats
```

Press `Ctrl+C` to stop.

---

## Step 9: Set Up Systemd Service for Auto-Start

```bash
sudo cp /opt/cyber-intel/cyber-intel.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable cyber-intel
sudo systemctl start cyber-intel

# Check status
sudo systemctl status cyber-intel
```

To view logs:
```bash
sudo journalctl -u cyber-intel -f
```

---

## Step 10: Configure Firewall (if needed)

Allow port 5000:

```bash
sudo ufw allow 5000/tcp
```

Or if using iptables:
```bash
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
```

---

## Step 11: Access Your Dashboard

Open in browser:
```
http://68.183.176.66:5000
```

---

## Step 12: Manual Testing

### Test News Scraper:
```bash
curl http://68.183.176.66:5000/api/refresh
```

### Test WhatsApp Alert:
```bash
curl -X POST http://68.183.176.66:5000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Security Alert",
    "url": "https://example.com",
    "severity": "critical"
  }'
```

---

## Step 13: Configure Auto-Refresh Schedule

The app automatically runs on this schedule (configured in `scheduler.py`):

- **News Scraper**: Every 2 hours
- **Daily WhatsApp Digest**: 9:00 AM daily

To modify, edit `scheduler.py`:

```python
# Change interval (in scheduler.py line 15)
scheduler.add_job(
    func=run_scraper,
    trigger="interval",
    hours=2,  # Change this number
)

# Change daily digest time (line 21)
scheduler.add_job(
    func=lambda: WhatsAppSender().send_daily_digest(),
    trigger="cron",
    hour=9,   # Change hour (0-23)
    minute=0,
)
```

Then restart:
```bash
sudo systemctl restart cyber-intel
```

---

## Step 14: Monitor Logs

```bash
# Real-time logs
sudo journalctl -u cyber-intel -f

# Last 50 lines
sudo journalctl -u cyber-intel -n 50
```

---

## Troubleshooting

### WhatsApp messages not sending?

1. Check Twilio credentials in `.env`:
```bash
cat /opt/cyber-intel/.env
```

2. Verify phone number format (must include country code: +1234567890)

3. Check logs:
```bash
sudo journalctl -u cyber-intel | grep -i whatsapp
```

### Dashboard not loading?

```bash
# Check if service is running
sudo systemctl status cyber-intel

# Restart service
sudo systemctl restart cyber-intel

# Check if port 5000 is open
netstat -tlnp | grep 5000
```

### Database issues?

```bash
# Delete old database
rm /opt/cyber-intel/data/security.db

# Reinitialize
cd /opt/cyber-intel && source venv/bin/activate
python3 << EOF
from app import app, db
with app.app_context():
    db.create_all()
EOF
```

---

## Backup & Maintenance

### Backup your database:
```bash
cp /opt/cyber-intel/data/security.db /opt/cyber-intel/data/security.db.backup
```

### Update source code:
```bash
cd /opt/cyber-intel
git pull origin main  # If using git
sudo systemctl restart cyber-intel
```

### View database:
```bash
cd /opt/cyber-intel && source venv/bin/activate
python3 << EOF
from app import app, SecurityNews
with app.app_context():
    news = SecurityNews.query.limit(5).all()
    for item in news:
        print(f"{item.severity}: {item.title}")
EOF
```

---

## Optional: Use Nginx as Reverse Proxy

For production, use Nginx in front of Flask:

```bash
sudo apt install nginx

sudo nano /etc/nginx/sites-available/cyber-intel
```

Paste:
```nginx
server {
    listen 80;
    server_name 68.183.176.66;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/cyber-intel /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

Now access at `http://68.183.176.66` (port 80)

---

## Summary

✅ **Deployed**: Cyber Security Intelligence System
✅ **WhatsApp Alerts**: Configured and working
✅ **Auto-Schedule**: Fetches every 2 hours, daily digest at 9 AM
✅ **Web Dashboard**: Accessible at http://68.183.176.66:5000
✅ **Auto-Start**: Service runs on boot

**You're all set! Your security intelligence hub is now live.** 🎉
