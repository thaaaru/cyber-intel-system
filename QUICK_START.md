# Quick Start Guide - 5 Minutes to Live

Get your Cyber Security Intelligence System running in 5 minutes.

---

## ⚡ TL;DR - Copy & Paste Commands

### Fastest Way (One Command)

```bash
git clone https://github.com/thaaaru/cyber-intel-system.git /opt/cyber-intel && \
sudo /opt/cyber-intel/deploy.sh
```

Then edit config and restart:
```bash
sudo nano /opt/cyber-intel/.env
sudo systemctl restart cyber-intel
```

### Alternative: Download & Run

```bash
cd /tmp
curl -O https://raw.githubusercontent.com/thaaaru/cyber-intel-system/main/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

### After Deployment

```bash
# 1. Edit Twilio credentials
sudo nano /opt/cyber-intel/.env

# 2. Restart service
sudo systemctl restart cyber-intel

# 3. Open dashboard
# Visit: http://your-server-ip:5000
```

---

## 🔐 Get Twilio Credentials (2 Minutes)

### Step 1: Create Free Twilio Account
- Go to https://www.twilio.com/try-twilio
- Sign up with email
- Create account

### Step 2: Get Your Credentials
1. Open [Twilio Console](https://www.twilio.com/console)
2. Copy **Account SID**
3. Copy **Auth Token**
4. Go to **Messaging → WhatsApp → Sandbox**
5. Copy **Sandbox Phone Number**
6. Note your **WhatsApp Number** (your phone: +1234567890)

### Step 3: Configure .env

```bash
nano /opt/cyber-intel/.env
```

Edit these 4 lines:

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_WHATSAPP_NUMBER=+14155552671
RECIPIENT_WHATSAPP_NUMBER=+1234567890
```

**Press Ctrl+X, Y, Enter to save**

---

## ✅ Verify Installation

```bash
# Check service is running
systemctl status cyber-intel

# Check logs
journalctl -u cyber-intel -n 20

# Test API
curl http://localhost:5000/api/stats
```

Expected output:
```json
{
  "critical": 0,
  "high": 0,
  "medium": 0,
  "low": 0,
  "total": 0,
  "today": 0
}
```

---

## 📱 Test WhatsApp Alert

```bash
curl -X POST http://localhost:5000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Alert - Critical Vulnerability Found",
    "url": "https://example.com",
    "severity": "critical"
  }'
```

Check your WhatsApp - you should receive a message!

---

## 🌐 Access Dashboard

Open in browser:
```
http://68.183.176.66:5000
```

You should see:
- 📊 Statistics cards (Critical, High, etc.)
- 🔄 Refresh News button
- 📱 Send WhatsApp Digest button
- 📰 News feed (empty initially)

---

## 🔄 First Run - Fetch News

Click **🔄 Refresh News** button on dashboard.

System will:
1. Scrape Bleeping Computer, Dark Reading, Krebs on Security
2. Fetch CVEs from NVD
3. Download CISA alerts
4. Add to database

Then reload the page to see articles!

---

## ⏰ Automatic Schedule

**Already running in background:**
- Every 2 hours: Fetch latest news
- Daily at 9 AM: Send WhatsApp digest

No action needed! ✨

---

## 🛑 Stop/Restart Service

```bash
# Stop
systemctl stop cyber-intel

# Restart
systemctl restart cyber-intel

# View real-time logs
journalctl -u cyber-intel -f
```

---

## ❓ Common Issues

### "WhatsApp not sending"
```bash
# Check Twilio credentials in .env
cat /opt/cyber-intel/.env

# Verify phone number format: +1234567890
# Restart service
systemctl restart cyber-intel

# Check logs
journalctl -u cyber-intel | grep -i whatsapp
```

### "Dashboard not loading"
```bash
# Check if service running
systemctl status cyber-intel

# Restart it
systemctl restart cyber-intel

# Check port 5000 is open
netstat -tlnp | grep 5000
```

### "No news appearing"
```bash
# Manually trigger scraper
curl http://localhost:5000/api/refresh

# Wait 2-3 seconds
sleep 3

# Refresh browser
# Should see news items now
```

---

## 📞 Support

**Error in logs?**
```bash
journalctl -u cyber-intel -n 100 | grep -i error
```

**Database issue?**
```bash
rm /opt/cyber-intel/data/security.db
systemctl restart cyber-intel
```

**Need detailed guide?**
```bash
cat /opt/cyber-intel/DEPLOYMENT.md
```

---

## 🎉 You're Done!

Your Cyber Security Intelligence System is now:

✅ **Running** on background (auto-starts on reboot)
✅ **Fetching news** every 2 hours automatically
✅ **Sending alerts** to WhatsApp
✅ **Displaying** in beautiful web dashboard

**Check your WhatsApp daily digest at 9 AM!** 📱

---

## 🚀 Next Steps

1. **Customize news sources**: Edit `scraper.py` to add more RSS feeds
2. **Change alert schedule**: Edit `scheduler.py` for different times
3. **Add authentication**: Modify `app.py` to require login
4. **Use Nginx**: Set up reverse proxy for SSL/HTTPS
5. **Backup database**: `cp data/security.db data/security.db.backup`

---

**Happy threat hunting!** 🔒
