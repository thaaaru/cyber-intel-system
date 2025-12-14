import feedparser
import requests
from bs4 import BeautifulSoup
from database import db, SecurityNews
from datetime import datetime, timedelta
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SecurityScraper:

    def __init__(self):
        self.sources = {
            'bleeping_computer': 'https://www.bleepingcomputer.com/feed/',
            'dark_reading': 'https://www.darkreading.com/rss.xml',
            'krebs_security': 'https://krebsonsecurity.com/feed/'
        }
        self.nvd_url = 'https://services.nvd.nist.gov/rest/json/cves/2.0'
        self.cisa_url = 'https://www.cisa.gov/news-events/alerts'

    def fetch_rss_feeds(self):
        """Fetch security news from RSS feeds"""
        for source_name, feed_url in self.sources.items():
            try:
                feed = feedparser.parse(feed_url)

                for entry in feed.entries[:10]:  # Last 10 articles
                    title = entry.get('title', '')
                    url = entry.get('link', '')
                    description = entry.get('summary', '')
                    published = entry.get('published', datetime.utcnow().isoformat())

                    # Check if already exists
                    existing = SecurityNews.query.filter_by(url=url).first()
                    if not existing:
                        # Determine severity based on keywords
                        severity = self._classify_severity(title + ' ' + description)

                        news = SecurityNews(
                            title=title,
                            source=source_name.replace('_', ' ').title(),
                            url=url,
                            description=description,
                            severity=severity,
                            category='news'
                        )
                        db.session.add(news)
                        logger.info(f"Added: {title[:50]}...")

                db.session.commit()

            except Exception as e:
                logger.error(f"Error fetching {source_name}: {str(e)}")

    def fetch_nvd_vulnerabilities(self):
        """Fetch critical CVEs from NVD API"""
        try:
            params = {
                'resultsPerPage': 20,
                'startIndex': 0,
                'cvssV3Severity': 'CRITICAL'
            }

            response = requests.get(self.nvd_url, params=params, timeout=10)
            data = response.json()

            for vuln in data.get('vulnerabilities', [])[:5]:
                cve_data = vuln.get('cve', {})
                cve_id = cve_data.get('id', '')
                description = cve_data.get('descriptions', [{}])[0].get('value', '')

                existing = SecurityNews.query.filter_by(url=f"nvd:{cve_id}").first()
                if not existing:
                    news = SecurityNews(
                        title=f"{cve_id}: Critical Vulnerability",
                        source='NVD',
                        url=f"nvd:{cve_id}",
                        description=description[:500],
                        severity='critical',
                        category='vulnerability'
                    )
                    db.session.add(news)
                    logger.info(f"Added CVE: {cve_id}")

            db.session.commit()

        except Exception as e:
            logger.error(f"Error fetching NVD: {str(e)}")

    def _classify_severity(self, text):
        """Classify severity based on keywords"""
        text_lower = text.lower()

        if any(word in text_lower for word in ['critical', 'zero-day', 'exploit', 'ransomware', 'active attack']):
            return 'critical'
        elif any(word in text_lower for word in ['breach', 'vulnerability', 'patch', 'vulnerability']):
            return 'high'
        elif any(word in text_lower for word in ['warning', 'alert', 'update']):
            return 'medium'

        return 'low'

def run_scraper():
    """Run the scraper"""
    scraper = SecurityScraper()
    logger.info("Starting security scraper...")
    scraper.fetch_rss_feeds()
    scraper.fetch_nvd_vulnerabilities()
    logger.info("Scraper completed")
