from flask import Flask, render_template, jsonify, request
from database import db, SecurityNews
from scheduler import start_scheduler
from scraper import run_scraper
from whatsapp_sender import WhatsAppSender
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data/security.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

with app.app_context():
    db.create_all()

# Start background scheduler
scheduler = start_scheduler(app)

@app.route('/')
def dashboard():
    """Main dashboard"""
    severity_filter = request.args.get('severity', '')
    source_filter = request.args.get('source', '')

    query = SecurityNews.query.order_by(SecurityNews.published_date.desc())

    if severity_filter:
        query = query.filter_by(severity=severity_filter)
    if source_filter:
        query = query.filter_by(source=source_filter)

    news_items = query.limit(50).all()

    stats = {
        'critical': SecurityNews.query.filter_by(severity='critical').count(),
        'high': SecurityNews.query.filter_by(severity='high').count(),
        'total': SecurityNews.query.count(),
        'today': SecurityNews.query.filter(
            SecurityNews.added_date >= datetime.utcnow() - timedelta(days=1)
        ).count()
    }

    return render_template('dashboard.html',
                         news=news_items,
                         stats=stats,
                         severity=severity_filter,
                         source=source_filter)

@app.route('/api/news')
def get_news_api():
    """API endpoint for news data"""
    limit = request.args.get('limit', 20, type=int)
    severity = request.args.get('severity', '')

    query = SecurityNews.query.order_by(SecurityNews.published_date.desc())

    if severity:
        query = query.filter_by(severity=severity)

    news = query.limit(limit).all()
    return jsonify([item.to_dict() for item in news])

@app.route('/api/refresh')
def refresh_news():
    """Manually trigger news refresh"""
    try:
        run_scraper()
        return jsonify({'status': 'success', 'message': 'News refreshed'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/send-alert', methods=['POST'])
def send_alert():
    """Manually send WhatsApp alert"""
    data = request.json
    sender = WhatsAppSender()
    success = sender.send_alert(data.get('title'), data.get('url'), data.get('severity'))
    return jsonify({'status': 'success' if success else 'error'})

@app.route('/api/stats')
def get_stats():
    """Get dashboard statistics"""
    stats = {
        'critical': SecurityNews.query.filter_by(severity='critical').count(),
        'high': SecurityNews.query.filter_by(severity='high').count(),
        'medium': SecurityNews.query.filter_by(severity='medium').count(),
        'low': SecurityNews.query.filter_by(severity='low').count(),
        'total': SecurityNews.query.count(),
        'today': SecurityNews.query.filter(
            SecurityNews.added_date >= datetime.utcnow() - timedelta(days=1)
        ).count()
    }
    return jsonify(stats)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
