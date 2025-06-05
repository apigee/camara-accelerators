# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from flask import Flask
from werkzeug.middleware.proxy_fix import ProxyFix
import logging
import os 
from oauth_routes import oauth_bp


app = Flask(__name__)
# Load secret key from environment variable, with a fallback for local development.
# IMPORTANT: For production in Cloud Run, FLASK_SECRET_KEY *must* be set as an environment variable.
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'change_this_to_a_strong_random_key_for_dev_only_if_not_using_env_var')

# Warn if the default/insecure key is used in a Cloud Run environment
if app.secret_key == 'change_this_to_a_strong_random_key_for_dev_only_if_not_using_env_var' and os.environ.get('K_SERVICE'):
    app.logger.warning('CRITICAL: FLASK_SECRET_KEY is not set to a secure value in the Cloud Run environment. Session security is compromised.')

app.config.update(
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True, # Good security practice
    SESSION_COOKIE_SAMESITE='None', 
)

app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_port=1, x_prefix=1)

# Configure logging using basicConfig with force=True
import sys # Ensure sys is imported for sys.stdout
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout,  # Explicitly direct to stdout, which Cloud Run captures
    force=True  # This will remove and re-add handlers, good for Gunicorn environments
)

# Ensure Flask's app.logger level is also set (it should inherit from root, but being explicit is fine)
app.logger.setLevel(logging.INFO)
# app.logger will use the root handlers configured by basicConfig if propagate=True (default)

# Register the OAuth blueprint 
app.register_blueprint(oauth_bp)
app.logger.info("Registered manual OAuth routes from oauth_routes.py. Login at /login.")

# Register general blueprints
from general_routes import general_bp
app.register_blueprint(general_bp)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
