from apscheduler.schedulers.background import BackgroundScheduler
from scraper import run_scraper
from whatsapp_sender import WhatsAppSender
import logging

logger = logging.getLogger(__name__)

def start_scheduler(app):
    """Start background scheduler"""
    scheduler = BackgroundScheduler()

    # Fetch news every 2 hours
    scheduler.add_job(
        func=run_scraper,
        trigger="interval",
        hours=2,
        id='scraper_job',
        name='Security News Scraper',
        replace_existing=True
    )

    # Send daily digest at 9 AM
    scheduler.add_job(
        func=lambda: WhatsAppSender().send_daily_digest(),
        trigger="cron",
        hour=9,
        minute=0,
        id='digest_job',
        name='Daily WhatsApp Digest',
        replace_existing=True
    )

    scheduler.start()
    logger.info("Scheduler started")

    return scheduler
