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

from flask import Blueprint, redirect, session, url_for, request, jsonify, make_response
import os
import logging 
import requests
import secrets
import hashlib
import base64
import urllib.parse
from datetime import datetime, timezone, timedelta
import jwt # For decoding ID token

# Firestore integration for OAuth state storage
try:
    from google.cloud import firestore
    db = firestore.Client()
    OAUTH_TRANSACTIONS_COLLECTION = 'oauth_temp_transactions' # Firestore collection name
    logging.info("Firestore client initialized successfully for OAuth transactions.") 
except Exception as e:
    logging.error(f"Failed to initialize Firestore client: {e}", exc_info=True) 
    db = None

oauth_bp = Blueprint('oauth', __name__)

# Load configuration from environment variables
OAUTH_CLIENT_ID = os.environ.get('OAUTH_CLIENT_ID', 'YOUR_OAUTH_CLIENT_ID')
OAUTH_CLIENT_SECRET = os.environ.get('OAUTH_CLIENT_SECRET', 'YOUR_OAUTH_CLIENT_SECRET')
OAUTH_AUTHORIZATION_ENDPOINT = os.environ.get('OAUTH_AUTHORIZATION_ENDPOINT', 'http://localhost:9000/authorize')
OAUTH_TOKEN_ENDPOINT = os.environ.get('OAUTH_TOKEN_ENDPOINT', 'http://localhost:9000/token')
# OAUTH_REDIRECT_URI from env should point to this app's /callback
# It will be used for constructing the redirect_uri for the IDP
# and for the token exchange.
EXPECTED_OAUTH_REDIRECT_URI = os.environ.get('OAUTH_REDIRECT_URI')

OAUTH_SCOPES = os.environ.get('OAUTH_SCOPES', 'sim-swap openid profile email')
PROVIDER_LOGOUT_URL = os.environ.get('OAUTH_LOGOUT_ENDPOINT')
APP_BASE_URL = os.environ.get('APP_BASE_URL', 'http://localhost:8080')



def generate_pkce_challenge(code_verifier):
    sha256_hash = hashlib.sha256(code_verifier.encode('utf-8')).digest()
    code_challenge = base64.urlsafe_b64encode(sha256_hash).rstrip(b'=').decode('utf-8')
    return code_challenge

@oauth_bp.route('/login')
def login():
    if not db:
        logging.error("Firestore client not available. OAuth login cannot proceed.")
        return jsonify({"error": "Server configuration error for OAuth."}), 500
    if not EXPECTED_OAUTH_REDIRECT_URI:
        logging.error("OAUTH_REDIRECT_URI environment variable is not set.")
        return jsonify({"error": "Server configuration error: OAUTH_REDIRECT_URI missing."}), 500

    try:
        from general_routes import stored_data # Import locally
    except ImportError:
        stored_data = {}
        logging.warning("Could not import stored_data from general_routes in oauth_routes.login.")

    try:
        transaction_id = secrets.token_urlsafe(32) # This will be the OAuth 'state'
        pkce_code_verifier = secrets.token_urlsafe(64)

        firestore_doc_data = {
            # 'app_csrf_token' no longer stored here
            'pkce_code_verifier': pkce_code_verifier,
            'created_at': datetime.now(timezone.utc)
        }
        db.collection(OAUTH_TRANSACTIONS_COLLECTION).document(transaction_id).set(firestore_doc_data)
        logging.info(f"Login: Stored PKCE verifier for transaction {transaction_id} in Firestore.")

        pkce_code_challenge = generate_pkce_challenge(pkce_code_verifier)
        
        params = {
            'response_type': 'code',
            'client_id': OAUTH_CLIENT_ID,
            'redirect_uri': EXPECTED_OAUTH_REDIRECT_URI, 
            'scope': OAUTH_SCOPES,
            'state': transaction_id, 
            'code_challenge': pkce_code_challenge,
            'code_challenge_method': 'S256',
        }
        if stored_data and 'msisdn' in stored_data:
            params['login_hint'] = stored_data['msisdn']
        
        authorization_url = f"{OAUTH_AUTHORIZATION_ENDPOINT}?{urllib.parse.urlencode(params)}"
        logging.info(f"Login: Redirecting to: {authorization_url}")
        
        # No separate CSRF cookie to set, direct redirect
        return redirect(authorization_url)

    except Exception as e:
        logging.error(f"Error in /login: {e}", exc_info=True)
        return jsonify({"error": "Login initiation failed", "message": str(e)}), 500

@oauth_bp.route('/callback')
def callback():
    if not db:
        logging.error("Firestore client not available. OAuth callback cannot proceed.")
        return jsonify({"error": "Server configuration error for OAuth."}), 500
    if not EXPECTED_OAUTH_REDIRECT_URI:
        logging.error("OAUTH_REDIRECT_URI environment variable is not set for callback validation.")
        return jsonify({"error": "Server configuration error: OAUTH_REDIRECT_URI missing."}), 500

    try:
        logging.info(f"Callback: Received request. Args: {request.args}")

        if 'error' in request.args:
            error = request.args.get('error')
            error_description = request.args.get('error_description', 'No description.')
            logging.error(f"OAuth Error in callback: {error} - {error_description}")
            return jsonify({"error": "OAuth authorization failed", "message": f"{error}: {error_description}"}), 400

        auth_code = request.args.get('code')
        incoming_transaction_id = request.args.get('state') # This is our transaction_id

        if not auth_code or not incoming_transaction_id:
            logging.error("Callback: Authorization code or state (transaction_id) missing.")
            return jsonify({"error": "Authorization code or state missing"}), 400

        # No separate CSRF cookie to check. Relying on unguessable transaction_id (state)
        # and one-time use from Firestore.

        doc_ref = db.collection(OAUTH_TRANSACTIONS_COLLECTION).document(incoming_transaction_id)
        doc = doc_ref.get()

        if not doc.exists:
            logging.error(f"Callback: Invalid transaction_id (state) or data expired/deleted: {incoming_transaction_id}")
            return jsonify({"error": "Invalid or expired state."}), 400

        stored_oauth_data = doc.to_dict()
        doc_ref.delete() # Delete after retrieving, one-time use
        logging.info(f"Callback: Deleted Firestore doc {incoming_transaction_id}")

        pkce_code_verifier = stored_oauth_data.get('pkce_code_verifier')
        

        if not pkce_code_verifier: 
            logging.error("Callback: PKCE code_verifier not found in Firestore document.")
            return jsonify({"error": "Internal error: Incomplete OAuth transaction data."}), 500
        
        logging.info("Callback: State (transaction_id) and PKCE verifier retrieved successfully from Firestore.")

        token_payload = {
            'grant_type': 'authorization_code',
            'code': auth_code,
            'redirect_uri': EXPECTED_OAUTH_REDIRECT_URI, 
            'client_id': OAUTH_CLIENT_ID,
            'code_verifier': pkce_code_verifier
        }
        auth = (OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET)
        
        logging.info(f"Callback: POSTing to token endpoint: {OAUTH_TOKEN_ENDPOINT}")
        token_exchange_response = requests.post(OAUTH_TOKEN_ENDPOINT, data=token_payload, auth=auth)
        
        logging.info(f"Callback: Token endpoint raw response status: {token_exchange_response.status_code}")
        logging.info(f"Callback: Token endpoint raw response text: {token_exchange_response.text[:500]}") # Log first 500 chars

        token_exchange_response.raise_for_status() # Check for HTTP errors (4xx, 5xx)
        
        try:
            token_data = token_exchange_response.json()
        except requests.exceptions.JSONDecodeError as json_err:
            logging.error(f"Callback: Failed to decode JSON from token endpoint. Error: {json_err}")
            logging.error(f"Callback: Raw response text that failed JSON parsing: {token_exchange_response.text}")
            return jsonify({"error": "Invalid response from token endpoint", "message": "Failed to parse token data."}), 500
            
        logging.info(f"Callback: Token endpoint response (parsed JSON): {token_data}")

        session['oauth_token_response'] = token_data
        
        # Decode ID Token and store user info in session
        id_token_str = token_data.get('id_token')
        if id_token_str:
            try:
                # WARNING: Decoding without verification is insecure for production!
                # For demo purposes only. In production, verify signature, aud, iss, exp, etc.
                decoded_id_token = jwt.decode(id_token_str, options={"verify_signature": False, "verify_aud": False})
                session['user'] = decoded_id_token # Store all claims
                logging.info(f"Callback: Decoded ID token and stored user info in session: {decoded_id_token}")
            except jwt.PyJWTError as jwt_err:
                logging.error(f"Callback: Failed to decode ID token: {jwt_err}", exc_info=True)
                session['user'] = {'sub': 'id_token_decode_error'} # Fallback user
        else:
            logging.warning("Callback: ID token not found in token response. Cannot populate session['user'] fully.")
            session['user'] = {'sub': 'unknown_user_no_id_token'} # Fallback user

        logging.info("Callback: Token obtained and stored in Flask session successfully.")
        return redirect(url_for('general.index'))

    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTPError during token exchange: {e.response.status_code} - {e.response.text}", exc_info=True)
        # No CSRF cookie to clear in this simplified flow's error path
        return jsonify({"error": "Token exchange failed", "message": str(e), "details": e.response.text if e.response else "No response body"}), 500
    except Exception as e:
        logging.error(f"Error in /callback: {e}", exc_info=True)
        # No CSRF cookie to clear in this simplified flow's error path
        return jsonify({"error": "Callback processing failed", "message": str(e)}), 500


@oauth_bp.route('/logout')
def logout():
    logging.info("Logout: Clearing local session data.")
    session.pop('user', None)
    session.pop('oauth_token_response', None) # Clearing the new session key for token

    # Provider logout (simplified, may need id_token_hint from stored token_response)
    if PROVIDER_LOGOUT_URL:
        token_response_data = session.get('oauth_token_response', {})
        id_token = token_response_data.get('id_token') # If ID token is in your token response

        params = {}
        if id_token:
            params['id_token_hint'] = id_token
        if APP_BASE_URL:
            params['post_logout_redirect_uri'] = url_for('general.index', _external=True)
        
        logout_url = PROVIDER_LOGOUT_URL
        if params:
            logout_url += "?" + urllib.parse.urlencode(params)
        
        logging.info(f"Logout: Redirecting to provider logout: {logout_url}")
        return redirect(logout_url)

    logging.info("Logout: Redirecting to general index (local logout only).")
    return redirect(url_for('general.index'))

def get_access_token_from_session():
    token_response = session.get('oauth_token_response')
    if token_response:
        # TODO: Implement token expiry check and refresh logic if refresh_token is available
        return token_response.get('access_token')
    return None
