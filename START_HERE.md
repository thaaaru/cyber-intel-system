# 🚀 START HERE - Complete Setup Guide

Welcome! Your complete **Cyber Security Intelligence System** is ready. Pick your deployment method and get started in minutes.

---

## ⚡ Fastest Way (5 Minutes)

### Option 1: Automated Deployment (Recommended)

```bash
# On your server (root@68.183.176.66)
cd /opt
curl -O https://your-repo-url/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

The script will:
✅ Install all dependencies
✅ Create Python environment
✅ Copy all files
✅ Initialize database
✅ Set up systemd service
✅ Start the service

Then edit .env with Twilio credentials and you're done!

---

### Option 2: Manual Copy + Automated Setup

```bash
# 1. Copy all files to server
scp -r /Users/tharaka/claude_space/mycti/cyber-intel-system/* root@68.183.176.66:/opt/cyber-intel/

# 2. SSH to server
ssh root@68.183.176.66

# 3. Run setup
cd /opt/cyber-intel
sudo chmod +x setup.sh
sudo ./setup.sh

# 4. Configure Twilio
nano .env
# Edit with your Twilio credentials

# 5. Start service
sudo systemctl start cyber-intel
```

---

### Option 3: Step-by-Step Manual (15 Minutes)

Follow the complete guide: **[DEPLOYMENT.md](DEPLOYMENT.md)**

---

## 🔐 Get Twilio Credentials (3 Minutes)

**Required for WhatsApp alerts**

1. Go to: https://www.twilio.com/try-twilio
2. Sign up with email
3. Go to [Twilio Console](https://www.twilio.com/console)
4. Copy **Account SID**
5. Copy **Auth Token**
6. Go to **Messaging → WhatsApp → Sandbox**
7. Copy **Sandbox Phone Number**
8. Note your phone as **Recipient Number** (e.g., +1234567890)

You now have 4 values to put in `.env` file.

---

## 📋 Quick Reference

### After Deployment

| Command | Purpose |
|---------|---------|
| `sudo systemctl status cyber-intel` | Check service status |
| `sudo systemctl restart cyber-intel` | Restart service |
| `sudo journalctl -u cyber-intel -f` | View live logs |
| `curl http://localhost:5000` | Test dashboard |
| `curl http://localhost:5000/api/stats` | Get statistics |

### File Locations

| Item | Location |
|------|----------|
| Dashboard | `http://server-ip:5000` |
| Configuration | `/opt/cyber-intel/.env` |
| Database | `/opt/cyber-intel/data/security.db` |
| Logs | `journalctl -u cyber-intel` |
| Service File | `/etc/systemd/system/cyber-intel.service` |

---

## 📚 Documentation Map

**Choose your guide:**

| Time | Path | Best For |
|------|------|----------|
| **5 min** | [QUICK_START.md](QUICK_START.md) | Just want it working |
| **10 min** | [deploy.sh](deploy.sh) script | Fully automated |
| **20 min** | [DEPLOYMENT.md](DEPLOYMENT.md) | Want full details |
| **5 min** | [README.md](README.md) | Understanding features |
| **15 min** | [SYSTEM_FLOW.md](SYSTEM_FLOW.md) | Want architecture |
| **30 min** | [INDEX.md](INDEX.md) | Complete reference |

---

## ✅ What You Get

Once deployed, you'll have:

- 🌐 **Web Dashboard** at `http://server:5000`
  - Real-time security news feed
  - Severity filtering (Critical/High/Medium/Low)
  - Statistics cards
  - Manual refresh & alert buttons
  - Dark theme UI

- 📱 **WhatsApp Alerts**
  - Daily digest at 9 AM
  - Critical alerts anytime
  - Manual send from dashboard
  - Twilio integration

- 🤖 **Automated Scraping**
  - Every 2 hours: Fetch latest news
  - Sources: Bleeping Computer, Dark Reading, Krebs, NVD, CISA
  - Auto-classification by severity
  - Deduplication

- 🔄 **Background Jobs**
  - Runs 24/7 automatically
  - Zero manual intervention
  - Survives server restart
  - Error handling & logging

---

## 🎯 3-Step Quick Start

### Step 1: Deploy (5 min)
```bash
cd /opt
curl -O https://your-repo/deploy.sh
sudo ./deploy.sh
```

### Step 2: Configure (2 min)
```bash
sudo nano /opt/cyber-intel/.env
# Edit with Twilio credentials
# Save and exit (Ctrl+X, Y, Enter)
```

### Step 3: Verify (2 min)
```bash
sudo systemctl restart cyber-intel
curl http://localhost:5000/api/stats
# Should return JSON with stats
```

**Done!** Dashboard is live at `http://your-ip:5000` 🎉

---

## 📞 Troubleshooting Quick Links

**Service won't start?**
```bash
sudo journalctl -u cyber-intel -n 50
sudo systemctl restart cyber-intel
```

**WhatsApp not working?**
- Check .env has correct Twilio credentials
- Verify phone number format: +1234567890
- Check you sent "join" to Twilio number first

**Dashboard not loading?**
```bash
netstat -tlnp | grep 5000
curl http://localhost:5000
```

**Need full troubleshooting?**
→ See [DEPLOYMENT.md](DEPLOYMENT.md) → Troubleshooting

---

## 🎓 Learning Path

### Just Want It Working?
1. Run `deploy.sh`
2. Edit `.env`
3. Restart service
4. Done!

### Want to Understand?
1. Read [README.md](README.md)
2. Read [SYSTEM_FLOW.md](SYSTEM_FLOW.md)
3. Run `deploy.sh`
4. Review code files
5. Customize as needed

### Complete Deep Dive?
1. Read [INDEX.md](INDEX.md)
2. Follow [DEPLOYMENT.md](DEPLOYMENT.md)
3. Review all code files
4. Check [SYSTEM_FLOW.md](SYSTEM_FLOW.md)
5. Extend with custom features

---

## 🚀 Deploy Now!

### Choose One:

#### Fastest (Fully Automated)
```bash
sudo /opt/cyber-intel/deploy.sh
```

#### Quick (With Template)
```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
cd /opt
mkdir -p cyber-intel
cd cyber-intel
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
nano .env
systemctl start cyber-intel
EOF
chmod +x deploy.sh
./deploy.sh
```

#### Manual (Following Guide)
→ Read [DEPLOYMENT.md](DEPLOYMENT.md)

---

## 💡 What Happens Next

### Immediately After Starting
✅ Service runs in background
✅ Starts scraping news
✅ Initializes database
✅ Dashboard available
✅ Ready for WhatsApp alerts

### Within 1 Hour
✅ First news items appear (50+)
✅ Statistics update
✅ Can send test alerts
✅ Can view dashboard

### Daily at 9 AM
✅ WhatsApp digest sent
✅ All critical alerts included
✅ Top high-priority items
✅ Dashboard link included

### Every 2 Hours
✅ Automatic news scraping
✅ Database updated
✅ Dashboard refreshes
✅ New alerts available

---

## 📊 System Requirements

| Requirement | What You Need |
|-------------|--------------|
| Server | Linux (Ubuntu/Debian) |
| CPU | 1 core minimum |
| RAM | 256 MB minimum, 512 MB+ recommended |
| Disk | 100 MB minimum |
| Python | 3.8+ |
| Internet | Required for news fetching |

---

## 💾 All Files Included

```
cyber-intel-system/
├── 📄 Python Code (5 files, 400 lines)
├── ⚙️ Configuration (4 files)
├── 🌐 Frontend (2 files)
├── 📚 Documentation (8 files)
├── 🚀 Scripts (2 files)
└── Ready to Deploy!
```

**Total**: 17 files, fully functional system

---

## 🔒 Security & Privacy

- ✅ Credentials in `.env` (not in git)
- ✅ Database stored locally
- ✅ No data sent except to Twilio
- ✅ Twilio communication encrypted (HTTPS)
- ✅ No personal data collected
- ✅ Open source & auditable

---

## 🎯 You're Ready!

### Pick Your Path:

**Just Deploy It** (5 min)
→ Run `deploy.sh`

**Understand First** (20 min)
→ Read documentation first

**Step by Step** (30 min)
→ Follow DEPLOYMENT.md

**Full Deep Dive** (1 hour)
→ Read everything, review code

---

## 📞 Need Help?

1. **Questions?** → Check [INDEX.md](INDEX.md)
2. **Setup problem?** → See [DEPLOYMENT.md](DEPLOYMENT.md)
3. **Want to understand?** → Read [SYSTEM_FLOW.md](SYSTEM_FLOW.md)
4. **Need to verify?** → Use [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
5. **Want all info?** → See [README.md](README.md)

---

## 🎉 Start Now!

```bash
# Copy this line and run on your server:
curl -O https://your-repo/deploy.sh && sudo ./deploy.sh
```

Your security intelligence system is ready to protect you. Let's go! 🚀🔒

---

**Questions?** See [INDEX.md](INDEX.md) for complete file reference.

**Happy threat hunting!** 🛡️
