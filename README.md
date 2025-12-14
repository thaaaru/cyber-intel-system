# Cyber Security Intelligence System

A complete automated solution to receive the most important cybersecurity updates and news via WhatsApp, with a beautiful web dashboard to view all threats in one place.

## 🎯 Features

- **Real-Time Security Alerts**: Critical CVEs, vulnerabilities, and breaches
- **Top Security News**: From Bleeping Computer, Dark Reading, Krebs on Security
- **WhatsApp Notifications**: Get instant alerts on your phone via Twilio
- **Beautiful Dashboard**: Modern web UI to view and manage all security intel
- **Auto-Scheduling**: Automatic news fetching every 2 hours + daily digest
- **Severity Filtering**: View critical, high, medium, or low priority items
- **One-Click Alerts**: Send any news item as a WhatsApp alert
- **No Manual Work**: Fully automated, runs in background

---

## 📊 System Architecture

```
Security Sources (NVD, CISA, RSS)
         ↓
   News Scraper
         ↓
   SQLite Database
      ↙        ↘
WhatsApp        Web Dashboard
Alerts          (Port 5000)
```

---

## 🚀 Quick Start

### Prerequisites
- Ubuntu/Debian server with Python 3.8+
- Twilio account (free)
- 5 minutes for setup

### Installation (3 Commands)

```bash
# 1. SSH into server and navigate
ssh root@68.183.176.66
cd /opt/cyber-intel

# 2. Copy files from this repo
# (Use SCP or git clone)

# 3. Run setup script
chmod +x setup.sh
./setup.sh
```

**Full detailed guide**: See `DEPLOYMENT.md`

---

## 📁 Project Structure

```
cyber-intel-system/
├── app.py                 # Flask web server
├── scraper.py            # News & CVE scraper
├── whatsapp_sender.py    # WhatsApp notifications
├── scheduler.py          # Background job scheduler
├── database.py           # SQLAlchemy models
├── requirements.txt      # Python dependencies
├── .env.example          # Configuration template
├── cyber-intel.service   # Systemd service file
├── templates/
│   └── dashboard.html    # Web dashboard UI
├── static/
│   └── style.css        # Dashboard styling
├── data/
│   └── security.db      # SQLite database
├── DEPLOYMENT.md        # Setup instructions
└── README.md           # This file
```

---

## 🔧 Configuration

### 1. Get Twilio Credentials

Visit [Twilio Console](https://www.twilio.com/console):
- **Account SID**: Your account identifier
- **Auth Token**: Your authentication token
- **WhatsApp Number**: Twilio-provided sandbox number
- **Recipient Number**: Your phone (e.g., +1234567890)

### 2. Create .env File

```bash
cp .env.example .env
nano .env
```

Fill in your Twilio credentials:
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_WHATSAPP_NUMBER=+14155552671
RECIPIENT_WHATSAPP_NUMBER=+1234567890
```

---

## 📱 WhatsApp Alerts

You'll receive alerts like this:

```
🚨 CRITICAL

Critical Vulnerability in Apache Log4j Found

🔗 https://example.com/full-article
```

### Alert Severity Levels
- 🚨 **Critical**: Zero-days, active exploits, ransomware
- ⚠️ **High**: Major vulnerabilities, breaches
- ⚡ **Medium**: Important updates, security warnings
- ℹ️ **Low**: General security news

---

## 🌐 Web Dashboard

Access at: `http://your-server-ip:5000`

**Features:**
- Real-time security news feed
- Filter by severity level
- Manual news refresh
- Send WhatsApp alerts
- Statistics dashboard
- Dark theme UI

---

## ⏰ Automatic Scheduling

By default, the system:
- **Every 2 hours**: Scrapes latest news from all sources
- **Daily at 9 AM**: Sends a digest of critical/high alerts
- **Real-time**: Updates database as new items arrive

To customize schedules, edit `scheduler.py`:

```python
# Change scrape interval
scheduler.add_job(
    func=run_scraper,
    trigger="interval",
    hours=2,  # Change to 1, 3, 4, etc.
)

# Change daily digest time
scheduler.add_job(
    func=lambda: WhatsAppSender().send_daily_digest(),
    trigger="cron",
    hour=9,   # Change to 6, 12, 15, etc. (24-hour format)
    minute=0,
)
```

---

## 📰 Security News Sources

The system monitors:

1. **Bleeping Computer** - Enterprise security & ransomware news
2. **Dark Reading** - Cybersecurity analysis & trends
3. **Krebs on Security** - In-depth security investigations
4. **NVD/CVE Database** - Critical vulnerabilities
5. **CISA Alerts** - Government security warnings

All sources are automatically fetched and deduplicated.

---

## 🔌 API Endpoints

```
GET  /                        # Dashboard UI
GET  /api/news                # Get all news (JSON)
GET  /api/stats               # Get statistics
GET  /api/refresh             # Trigger scraper
POST /api/send-alert          # Send WhatsApp alert
```

Example API call:
```bash
curl http://your-server:5000/api/stats

# Response:
{
  "critical": 3,
  "high": 12,
  "medium": 45,
  "low": 128,
  "total": 188,
  "today": 8
}
```

---

## 🔐 Security Considerations

- **Database**: SQLite stored locally (password-protected if needed)
- **WhatsApp**: Uses Twilio's encrypted API
- **Environment Variables**: Credentials stored in .env (not in code)
- **Dashboard**: No authentication (add if exposing publicly)

For production, consider:
- Adding basic authentication to dashboard
- Using HTTPS/SSL certificate
- Running behind Nginx reverse proxy
- Restricting API access

---

## 🛠️ Maintenance

### View Logs
```bash
sudo journalctl -u cyber-intel -f
```

### Restart Service
```bash
sudo systemctl restart cyber-intel
```

### Backup Database
```bash
cp data/security.db data/security.db.backup
```

### Update Code
```bash
cd /opt/cyber-intel
# Pull latest changes
git pull origin main
sudo systemctl restart cyber-intel
```

---

## 📊 Database Schema

### SecurityNews Table
```sql
id              INTEGER PRIMARY KEY
title           VARCHAR(500)        -- Article title
source          VARCHAR(100)        -- News source
url             VARCHAR(500)        -- Unique article URL
description     TEXT                -- Article summary
severity        VARCHAR(20)         -- critical/high/medium/low
published_date  DATETIME            -- When article was published
added_date      DATETIME            -- When added to system
category        VARCHAR(100)        -- vulnerability/breach/news/alert
sent_to_whatsapp BOOLEAN            -- If sent as WhatsApp alert
```

---

## 🚨 Troubleshooting

### WhatsApp alerts not working?
1. Check `.env` file has correct credentials
2. Verify phone number format: `+1234567890` (with + and country code)
3. Check Twilio sandbox - must send "join" first
4. View logs: `sudo journalctl -u cyber-intel | grep -i whatsapp`

### Dashboard not loading?
1. Check service: `sudo systemctl status cyber-intel`
2. Check port: `netstat -tlnp | grep 5000`
3. Restart: `sudo systemctl restart cyber-intel`

### No news items appearing?
1. Manually trigger scraper: `curl http://localhost:5000/api/refresh`
2. Check database: `python3 check_db.py`
3. View error logs: `sudo journalctl -u cyber-intel -n 100`

---

## 📈 Performance

- **Memory**: ~100-150 MB
- **Storage**: ~10 MB per 1000 news items
- **Response Time**: <500ms for dashboard
- **Concurrent Users**: Suitable for 10+ simultaneous users

---

## 📝 License

Open source - modify and use freely.

---

## 💡 Future Enhancements

- Slack/Discord integration
- Email alerts
- Custom keyword filtering
- Threat intelligence integration
- Machine learning severity classification
- API key authentication
- Multi-user dashboard
- Dark/light mode toggle

---

## 🤝 Support

For issues:
1. Check `DEPLOYMENT.md` for setup issues
2. Review logs: `sudo journalctl -u cyber-intel`
3. Test manually: `curl http://localhost:5000/api/stats`

---

**Made with ❤️ for cybersecurity professionals**

Happy threat hunting! 🔒
