"""Main Flask application for DeployGuard."""

from flask import Flask, jsonify, request
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# Metrics
REQUEST_COUNT = Counter('request_count', 'Total HTTP requests', ['method', 'endpoint'])

def create_app():
    app = Flask(__name__)

    @app.before_request
    def before_request():
        REQUEST_COUNT.labels(method=request.method, endpoint=request.path).inc()

    @app.route('/')
    def index():
        return jsonify({'message': 'DeployGuard is running'})

    @app.route('/health')
    def health():
        return jsonify({'status': 'healthy'}), 200

    @app.route('/version')
    def version():
        return jsonify({'version': '0.1.0'}), 200

    @app.route('/metrics')
    def metrics():
        return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

    return app

if __name__ == '__main__':
    # Run with gunicorn in production
    from werkzeug.middleware.dispatcher import DispatcherMiddleware
    app = create_app()
    app.run(host='0.0.0.0', port=5000)
