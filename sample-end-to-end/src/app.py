from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix
import secrets
import logging
from oauth_routes import oauth_bp, init_oauth
from general_routes import general_bp

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1)

logging.basicConfig(level=logging.INFO)

# Initialize OAuth
init_oauth(app)

# Register the blueprints
#app.register_blueprint(oauth_bp, url_prefix='/oauth')
app.register_blueprint(oauth_bp)
app.register_blueprint(general_bp)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))