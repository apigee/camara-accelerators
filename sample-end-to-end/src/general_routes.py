from flask import Blueprint, render_template, request, jsonify, flash, redirect, url_for, session
import logging
from camara_calls import check_sim_swap
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
    user_info = session.get('user')
    return render_template("index.html", balance=account_balance, user=user_info, stored_msisdn=stored_data["msisdn"], stored_config_type=stored_data["config_type"])

@general_bp.route("/transfer", methods=["POST"])
def transfer():
    """Handles the money transfer request. Requires user to be logged in."""
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
                access_token = session.get('token', {}).get('access_token')
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
