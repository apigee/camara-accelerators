from flask import Blueprint, redirect, session, url_for, jsonify
from authlib.integrations.flask_client import OAuth
from general_routes import stored_data
import os
import logging
import urllib
import requests

oauth_bp = Blueprint('oauth', __name__)

oauth = OAuth()

def init_oauth(app):
    oauth.init_app(app)
    oauth.register(
        name='apigee_idp_facade',
        client_id=os.environ.get('OAUTH_CLIENT_ID', 'YOUR_OAUTH_CLIENT_ID'),
        client_secret=os.environ.get('OAUTH_CLIENT_SECRET', 'YOUR_OAUTH_CLIENT_SECRET'),
        authorize_url=os.environ.get('OAUTH_AUTHORIZATION_ENDPOINT', 'http://localhost:9000/authorize'),
        authorize_params=None,
        access_token_url=os.environ.get('OAUTH_TOKEN_ENDPOINT', 'http://localhost:9000/token'),
        access_token_params=None,
        redirect_uri=os.environ.get('OAUTH_REDIRECT_URI', 'http://localhost:8080/callback'),
        userinfo_endpoint=os.environ.get('OAUTH_USERINFO_ENDPOINT', 'http://localhost:9000/userinfo'),
        client_kwargs={'login_hint': stored_data['msisdn'],'scope': 'sim-swap openid profile email', 'code_challenge_method': 'S256'},  # Adjust scopes as needed
        jwks_uri=os.environ.get('OAUTH_JWKS_URI', 'http://localhost:9000/.well-known/jwks.json') # Add the jwks_uri to perform local token validation
    )

@oauth_bp.route('/login')
def login():
    """Initiates the OAuth 2.0 Authorization Code Flow."""
    redirect_uri = os.environ.get('OAUTH_REDIRECT_URI')
    if not redirect_uri:
        raise EnvironmentError("OAUTH_REDIRECT_URI is not set in the environment.")
    return oauth.apigee_idp_facade.authorize_redirect(redirect_uri)

@oauth_bp.route('/callback')
def callback():
    """Handles the callback from the OAuth provider."""
    token = oauth.apigee_idp_facade.authorize_access_token()
    # Validate the ID token
    try:
        # oauth.apigee_idp_facade.fetch_jwk_set()
        # claims = oauth.apigee_idp_facade.parse_id_token(token, nonce=None)
        # claims.validate()  # Check if the token is valid (not expired, etc.)

        # Store user information in the session
        user_info = oauth.apigee_idp_facade.userinfo(token=token) # Use OIDC userinfo endpoint

        session['user'] = user_info
        session['token'] = token

        return redirect(url_for('general.index'))

    except Exception as e:
        # Handle token validation errors
        return jsonify({"error": "Invalid token", "message": str(e)}), 401


@oauth_bp.route('/logout')
def logout():
    """Logs the user out locally and optionally from the provider."""
    session.pop('user', None)

    # Optional: Redirect to the provider's logout endpoint for single logout
    provider_logout_url = os.environ.get('OAUTH_LOGOUT_ENDPOINT', 'http://localhost:9000/logout')

    if provider_logout_url:
        access_token = session.get('token', {}).get('access_token')
        if access_token:
            headers = {
                'Authorization': f'Bearer {access_token}'
            }

            # Add id_token_hint as query parameter
            params = {}
            id_token = session.get('token', {}).get('idp.jwt')
            if id_token:
              params['id_token_hint'] = id_token
            
            app_base_url = os.environ.get('APP_BASE_URL', 'http://localhost:8080')
            if app_base_url:
              params['post_logout_redirect_uri'] = app_base_url

            try:
                # Make a POST request to the logout endpoint
                response = requests.post(f"{provider_logout_url}?" + urllib.parse.urlencode(params), headers=headers, verify=False) # Consider security implications
                response.raise_for_status()  # Raise an exception for bad status codes
            except requests.exceptions.RequestException as e:
                logging.error(f"Error during logout: {e}")

    return redirect(url_for('general.index'))
