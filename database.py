from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class SecurityNews(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(500), nullable=False)
    source = db.Column(db.String(100), nullable=False)  # Bleeping Computer, Dark Reading, etc.
    url = db.Column(db.String(500), unique=True, nullable=False)
    description = db.Column(db.Text)
    severity = db.Column(db.String(20), default='medium')  # critical, high, medium, low
    published_date = db.Column(db.DateTime, default=datetime.utcnow)
    added_date = db.Column(db.DateTime, default=datetime.utcnow)
    category = db.Column(db.String(100))  # vulnerability, breach, alert, news
    sent_to_whatsapp = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'source': self.source,
            'url': self.url,
            'description': self.description,
            'severity': self.severity,
            'published_date': self.published_date.strftime('%Y-%m-%d %H:%M'),
            'category': self.category
        }
