from twilio.rest import Client
from database import db, SecurityNews
import os
import logging

logger = logging.getLogger(__name__)

class WhatsAppSender:

    def __init__(self):
        self.account_sid = os.getenv('TWILIO_ACCOUNT_SID')
        self.auth_token = os.getenv('TWILIO_AUTH_TOKEN')
        self.twilio_whatsapp_number = os.getenv('TWILIO_WHATSAPP_NUMBER')
        self.recipient_number = os.getenv('RECIPIENT_WHATSAPP_NUMBER')

        if not all([self.account_sid, self.auth_token, self.twilio_whatsapp_number, self.recipient_number]):
            logger.error("Missing Twilio configuration in .env file")
            return

        self.client = Client(self.account_sid, self.auth_token)

    def send_alert(self, title, url, severity):
        """Send critical alert via WhatsApp"""

        emoji_map = {
            'critical': '🚨',
            'high': '⚠️',
            'medium': '⚡',
            'low': 'ℹ️'
        }

        emoji = emoji_map.get(severity, 'ℹ️')
        message = f"{emoji} *{severity.upper()}*\n\n{title}\n\n🔗 {url}"

        try:
            self.client.messages.create(
                from_=f'whatsapp:{self.twilio_whatsapp_number}',
                to=f'whatsapp:{self.recipient_number}',
                body=message
            )
            logger.info(f"WhatsApp alert sent: {title[:50]}...")
            return True
        except Exception as e:
            logger.error(f"Failed to send WhatsApp message: {str(e)}")
            return False

    def send_daily_digest(self):
        """Send daily digest of top critical/high severity news"""

        critical = SecurityNews.query.filter_by(severity='critical', sent_to_whatsapp=False).all()
        high = SecurityNews.query.filter_by(severity='high', sent_to_whatsapp=False).limit(3).all()

        if not critical and not high:
            logger.info("No unsent alerts to send")
            return

        message = "📊 *Security Intelligence Digest*\n\n"

        if critical:
            message += "🚨 *CRITICAL ALERTS:*\n"
            for item in critical[:5]:
                message += f"• {item.title[:50]}...\n"
            message += "\n"

        if high:
            message += "⚠️ *HIGH PRIORITY:*\n"
            for item in high:
                message += f"• {item.title[:50]}...\n"

        message += "\n👉 View full details: http://your-server-ip:5000"

        try:
            self.client.messages.create(
                from_=f'whatsapp:{self.twilio_whatsapp_number}',
                to=f'whatsapp:{self.recipient_number}',
                body=message
            )

            # Mark as sent
            for item in critical + high:
                item.sent_to_whatsapp = True
            db.session.commit()

            logger.info("Daily digest sent")
        except Exception as e:
            logger.error(f"Failed to send digest: {str(e)}")
