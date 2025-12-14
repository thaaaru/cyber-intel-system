# Deployment Checklist ✓

Use this checklist to ensure everything is set up correctly.

---

## 📋 Pre-Deployment (Before You Start)

- [ ] Have SSH access to `root@68.183.176.66`
- [ ] Have Twilio account created (free)
- [ ] Have your WhatsApp phone number ready (e.g., +1234567890)
- [ ] Have all project files downloaded
- [ ] Verified server has Python 3.8+
- [ ] Verified server has internet access

---

## 🔧 Setup Phase (Steps 1-5)

### Step 1: SSH Access
- [ ] Can connect: `ssh root@68.183.176.66`
- [ ] Have sudo privileges
- [ ] Can create directories in /opt
- [ ] Can run systemctl commands

### Step 2: Project Setup
- [ ] Created `/opt/cyber-intel` directory
- [ ] Copied all project files to server
- [ ] Files copied correctly:
  - [ ] `app.py`
  - [ ] `scraper.py`
  - [ ] `whatsapp_sender.py`
  - [ ] `scheduler.py`
  - [ ] `database.py`
  - [ ] `requirements.txt`
  - [ ] `templates/dashboard.html`
  - [ ] `static/style.css`
  - [ ] `cyber-intel.service`
  - [ ] All documentation files

### Step 3: Virtual Environment
- [ ] Python venv created: `python3 -m venv venv`
- [ ] Activated: `source venv/bin/activate`
- [ ] Pip upgraded: `pip install --upgrade pip`
- [ ] No errors in activation

### Step 4: Dependencies Installation
- [ ] All packages installed: `pip install -r requirements.txt`
- [ ] No error messages during install
- [ ] Verified: `pip list | grep Flask`
- [ ] Verified: `pip list | grep twilio`
- [ ] Verified: `pip list | grep SQLAlchemy`

### Step 5: Database Initialization
- [ ] Database created successfully
- [ ] No errors in initialization
- [ ] `data/security.db` file exists
- [ ] File size > 0 bytes

---

## 🔐 Twilio Setup (Steps 6-8)

### Step 6: Twilio Account & Credentials
- [ ] Signed up at https://www.twilio.com
- [ ] Verified email address
- [ ] Have Account SID (starts with AC...)
- [ ] Have Auth Token (long random string)
- [ ] Have WhatsApp Sandbox phone (e.g., +14155552671)

### Step 7: WhatsApp Sandbox Activation
- [ ] Opted into WhatsApp Sandbox
- [ ] Sent "join" message to Twilio number (got confirmation)
- [ ] Your WhatsApp number confirmed
- [ ] Know your recipient number format: +1234567890

### Step 8: Configuration File
- [ ] Created `.env` file in `/opt/cyber-intel`
- [ ] Added TWILIO_ACCOUNT_SID
- [ ] Added TWILIO_AUTH_TOKEN
- [ ] Added TWILIO_WHATSAPP_NUMBER
- [ ] Added RECIPIENT_WHATSAPP_NUMBER
- [ ] Verified all values correct (no spaces, full format)
- [ ] File saved and readable

---

## 🚀 Service Setup (Steps 9-11)

### Step 9: Systemd Service File
- [ ] Copied `cyber-intel.service` to `/etc/systemd/system/`
- [ ] File is readable
- [ ] WorkingDirectory is `/opt/cyber-intel`
- [ ] ExecStart path is correct
- [ ] Enabled auto-start: `systemctl enable cyber-intel`

### Step 10: Service Start & Verification
- [ ] Service started: `systemctl start cyber-intel`
- [ ] No startup errors: `systemctl status cyber-intel`
- [ ] Service shows as "active (running)"
- [ ] Process is running: `ps aux | grep python`

### Step 11: Log Verification
- [ ] Logs show no errors: `journalctl -u cyber-intel -n 20`
- [ ] Scheduler started successfully
- [ ] Database operations completed without errors
- [ ] Service running for >10 seconds without restart

---

## 🌐 Web Dashboard (Steps 12-14)

### Step 12: Port Verification
- [ ] Port 5000 is open: `netstat -tlnp | grep 5000`
- [ ] Service listening on 0.0.0.0:5000
- [ ] Firewall allows port 5000 (if applicable)
- [ ] No permission denied errors

### Step 13: Dashboard Access
- [ ] Open browser: `http://68.183.176.66:5000`
- [ ] Page loads successfully
- [ ] No 404 or connection errors
- [ ] Dashboard displays with dark theme
- [ ] All CSS loads correctly

### Step 14: Dashboard Components
- [ ] Header visible: "Cyber Security Intelligence Hub"
- [ ] Control buttons visible:
  - [ ] "🔄 Refresh News" button
  - [ ] "📱 Send WhatsApp Digest" button
  - [ ] Severity filter dropdown
- [ ] Statistics cards visible (Critical, High, Medium, Total)
- [ ] News list area visible (even if empty initially)

---

## 📱 WhatsApp Testing (Steps 15-17)

### Step 15: Manual News Scrape
- [ ] Clicked "🔄 Refresh News" button
- [ ] Got success message
- [ ] Waited 2-3 seconds
- [ ] Refreshed dashboard with F5
- [ ] News items appeared in feed
- [ ] Statistics updated (show > 0 items)

### Step 16: Test WhatsApp Alert
- [ ] Found a news item on dashboard
- [ ] Clicked "Send Alert" button
- [ ] Got "Alert sent" confirmation
- [ ] 📱 Received WhatsApp message on phone
- [ ] Message format correct with emoji and link
- [ ] Message arrived within 5 seconds

### Step 17: API Testing
- [ ] Test stats API: `curl http://localhost:5000/api/stats`
- [ ] Got JSON response with counts
- [ ] Test news API: `curl http://localhost:5000/api/news?limit=5`
- [ ] Got JSON array of news items
- [ ] Each item has: title, source, url, severity

---

## ⏰ Scheduler Verification (Steps 18-20)

### Step 18: Scraper Scheduling
- [ ] APScheduler initialized in logs
- [ ] Job scheduled: "Security News Scraper"
- [ ] Job interval: every 2 hours
- [ ] No scheduler errors in logs

### Step 19: Daily Digest Scheduling
- [ ] Job scheduled: "Daily WhatsApp Digest"
- [ ] Scheduled time: 9:00 AM
- [ ] Next run time shown in logs
- [ ] Cron job configured correctly

### Step 20: Background Job Verification
- [ ] Service runs 24/7 (checked after 1 hour)
- [ ] CPU usage is low (<5%)
- [ ] Memory usage is reasonable (~100-150 MB)
- [ ] No restart messages in logs
- [ ] No memory leak warnings

---

## 🔒 Security & Production (Steps 21-23)

### Step 21: Credentials Security
- [ ] `.env` file has restrictive permissions: `chmod 600 .env`
- [ ] `.env` is not in git repository (check .gitignore)
- [ ] No Twilio credentials in any code files
- [ ] No credentials in logs: `journalctl -u cyber-intel | grep -i token`
- [ ] API tokens not printed anywhere

### Step 22: Database Backup
- [ ] Created backup location: `/opt/cyber-intel/backups/`
- [ ] Backup script created (optional)
- [ ] Can restore from backup (tested)
- [ ] Automated daily backup (optional)

### Step 23: Monitoring Setup
- [ ] Set up log rotation (if using Nginx)
- [ ] Monitoring of disk space (optional)
- [ ] CPU/Memory limits set (optional)
- [ ] Alert system for crashes (optional)

---

## 📊 Data & Performance (Steps 24-26)

### Step 24: Database Status
- [ ] Database file exists: `/opt/cyber-intel/data/security.db`
- [ ] File size > 1 MB (has data)
- [ ] No corruption warnings
- [ ] Can query records: works in Python shell

### Step 25: News Feed Population
- [ ] Database has >0 news items
- [ ] Multiple sources represented (Bleeping, Dark Reading, Krebs)
- [ ] News items have correct severity levels
- [ ] Dates are recent (today/yesterday)

### Step 26: Performance Testing
- [ ] Dashboard loads in <1 second
- [ ] News filtering works smoothly
- [ ] Refresh button responds <2 seconds
- [ ] API responses in JSON <500ms
- [ ] No timeout errors

---

## 🔄 Automated Operation (Steps 27-29)

### Step 27: Automatic Scheduling Test
- [ ] Wait until next 2-hour interval
- [ ] Check logs: new scrape started automatically
- [ ] New items added to database
- [ ] Dashboard updates automatically
- [ ] No manual intervention needed

### Step 28: Daily Digest Test (if possible)
- [ ] Can manually trigger: edit scheduler.py for testing
- [ ] Receives WhatsApp digest message
- [ ] Message format correct
- [ ] Database marked items as sent
- [ ] No duplicate messages

### Step 29: Service Persistence
- [ ] Reboot server: `reboot`
- [ ] Wait 2 minutes
- [ ] Service auto-started after reboot
- [ ] Dashboard accessible again
- [ ] Scheduler running again
- [ ] News feed still populated

---

## 📝 Documentation & Training (Steps 30-32)

### Step 30: Documentation Review
- [ ] Read README.md (5 min)
- [ ] Understood system architecture
- [ ] Understood data flow
- [ ] Know how to troubleshoot

### Step 31: Log Understanding
- [ ] Can read service logs
- [ ] Understand error messages
- [ ] Know how to filter logs
- [ ] Know where to look for issues

### Step 32: Customization Readiness
- [ ] Know how to edit scraper.py to add sources
- [ ] Know how to change scheduler.py times
- [ ] Know how to modify database.py schema
- [ ] Understand API endpoints in app.py

---

## 🎉 Post-Deployment (Final Steps)

### Step 33: Final Verification
- [ ] All systems running (status green)
- [ ] Dashboard accessible and responsive
- [ ] WhatsApp messages working
- [ ] Daily digest scheduled for tomorrow
- [ ] Logs show no errors

### Step 34: Documentation
- [ ] Saved all credentials securely
- [ ] Noted server IP: 68.183.176.66
- [ ] Noted dashboard URL: http://68.183.176.66:5000
- [ ] Have backup of .env file (secure location)
- [ ] Have recovery procedures documented

### Step 35: Notification Setup
- [ ] Added phone number to daily digest
- [ ] Verified WhatsApp number works
- [ ] Have contact info for Twilio support
- [ ] Know how to restart service if needed
- [ ] Set calendar reminder to check dashboard weekly

---

## ✅ Deployment Complete!

Once all checkboxes above are marked, your system is fully deployed and operational!

### Daily Operations
- ✅ WhatsApp digest arrives at 9 AM
- ✅ News updated every 2 hours automatically
- ✅ Check dashboard for details as needed
- ✅ Send manual alerts as required

### Weekly Checks
- [ ] Monday: Check dashboard for past week's threats
- [ ] Wednesday: Verify WhatsApp alerts working
- [ ] Friday: Review critical items from the week
- [ ] Monthly: Backup database

### Monthly Maintenance
- [ ] Check disk space: `df -h /opt/cyber-intel`
- [ ] Database size: `du -sh /opt/cyber-intel/data/`
- [ ] Logs size: check log retention
- [ ] Add new security sources if needed
- [ ] Review and archive old items

---

## 🆘 If Something Fails

### Check Service Status
```bash
sudo systemctl status cyber-intel
sudo journalctl -u cyber-intel -n 50
```

### Restart Service
```bash
sudo systemctl restart cyber-intel
sleep 5
sudo systemctl status cyber-intel
```

### Check Connectivity
```bash
curl http://localhost:5000
curl http://localhost:5000/api/stats
```

### Verify Twilio
```bash
# Check .env
cat /opt/cyber-intel/.env | grep TWILIO

# Check logs for errors
journalctl -u cyber-intel | grep -i twilio
```

### Database Issues
```bash
# Delete and recreate
rm /opt/cyber-intel/data/security.db
systemctl restart cyber-intel
```

---

## 📞 Support Resources

- **Issue with Twilio?** → https://www.twilio.com/console/support
- **Issue with Flask?** → https://flask.palletsprojects.com/
- **Issue with database?** → Check logs with journalctl
- **Need to modify code?** → Edit files in `/opt/cyber-intel/`

---

## 🎯 Success Criteria Met When

- [ ] Dashboard loads and shows data
- [ ] WhatsApp messages send successfully
- [ ] Automatic scraping runs every 2 hours
- [ ] Daily digest arrives at 9 AM
- [ ] Service survives server reboot
- [ ] All documentation reviewed
- [ ] No unresolved errors in logs
- [ ] Can access from multiple devices

---

**Your Cyber Security Intelligence System is now LIVE! 🚀🔒**

Start monitoring, stay informed, and keep your organization secure.
