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

from flask import Blueprint, render_template, request, jsonify, flash, redirect, url_for, session
import logging
from camara_calls import check_sim_swap
# from oauth_routes import get_access_token_from_session # Import moved into transfer()
from datetime import datetime, timedelta


general_bp = Blueprint('general', __name__)

# Mock account balance
account_balance = 10000


stored_data = {
    "msisdn": "tel:+5511123456789",
    "config_type": "sim_swap"
}

@general_bp.route("/")
def index():
    """Renders the main page with the transfer form. Displays user info if logged in."""
    logging.info(f"General Index: Attempting to access session data.")
    user_info = session.get('user')
    token_response_present = 'oauth_token_response' in session
    
    logging.info(f"General Index: user_info from session: {user_info}")
    logging.info(f"General Index: 'oauth_token_response' present in session: {token_response_present}")
    logging.info(f"General Index: 'oauth_token_response': {session.get('oauth_token_response')}")
    if token_response_present:
        # Optionally log parts of the token response, e.g., if access_token exists
        access_token_present = bool(session.get('oauth_token_response', {}).get('access_token'))
        logging.info(f"General Index: Access token present in oauth_token_response: {access_token_present}")

    return render_template("index.html", balance=account_balance, user=user_info, stored_msisdn=stored_data["msisdn"], stored_config_type=stored_data["config_type"])

@general_bp.route("/transfer", methods=["POST"])
def transfer():
    """Handles the money transfer request. Requires user to be logged in."""
    from oauth_routes import get_access_token_from_session # Moved import here
    global account_balance
    if not session.get('user'):
        return redirect(url_for('oauth.login'))

    try:
        amount = float(request.form["amount"])
        if amount <= 0:
            return jsonify({"status": "error", "message": "Invalid amount. Please enter a positive value."})
        if amount > account_balance:
            return jsonify({"status": "error", "message": "Insufficient funds."})

        if amount > 200:
        # Check for recent SIM swap using phone number from stored_data
            phone_number = stored_data.get("msisdn")
            if phone_number:
                access_token = get_access_token_from_session() # Use the helper function
                if access_token:
                    sim_swap_info = check_sim_swap(access_token, phone_number)
                    if sim_swap_info['error']:
                        logging.error(f"SIM Swap check error: {sim_swap_info['error']}")
                        # Handle error (e.g., display a message to the user, but don't block the transfer)
                    else:
                        last_swap_date = sim_swap_info['last_swap_date']
                        if last_swap_date:
                            two_days_ago = datetime.now() - timedelta(days=2)
                            if last_swap_date > two_days_ago:
                                return jsonify({"status": "error", "message": "Transfer blocked due to recent SIM swap. Please contact customer service."})
            else:
                logging.error("Phone number not found in stored_data.")
                # Handle the case where the phone number is not available

        account_balance -= amount
        return jsonify({"status": "success", "message": f"Transferred ${amount:.2f}. New balance: ${account_balance:.2f}"})

    except ValueError:
        return jsonify({"status": "error", "message": "Invalid amount format."})


@general_bp.route('/submit-config', methods=['POST'])
def submit_config():
    global stored_data
    # if not session.get('user'):
    #     return jsonify({"status": "error", "message": "User not logged in."}), 401

    msisdn = request.form.get('msisdn')
    config_type = request.form.get('configType')

    stored_data["msisdn"] = msisdn
    stored_data["config_type"] = config_type

    logging.info(f"Received and stored msisdn: {msisdn}, config_type: {config_type}")
    flash('Configuration updated successfully!', 'success')

    return redirect(url_for('general.index'))
