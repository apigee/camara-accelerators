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

import requests
import os
from datetime import datetime, timedelta

def check_sim_swap(access_token, phone_number):
    """
    Checks the SIM Swap API for the last SIM swap date.

    Args:
        access_token: The OAuth access token.
        phone_number: The phone number to check.

    Returns:
        A dictionary containing:
        - 'last_swap_date': A datetime object representing the last SIM swap date, or None if no swap found or error.
        - 'error': An error message string, or None if no error.
    """
    sim_swap_api_url = os.environ.get('SIM_SWAP_API_URL')
    if not sim_swap_api_url:
        return {'last_swap_date': None, 'error': 'SIM_SWAP_API_URL environment variable not set'}

    headers = {
        'Authorization': f'Bearer {access_token}'
    }

    payload = {
        'phoneNumber': phone_number
    }

    try:
        response = requests.post(f'{sim_swap_api_url}/retrieve-date', headers=headers, json=payload)
        response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)

        data = response.json()
        # Assuming the API returns a date string in ISO 8601 format (YYYY-MM-DD)
        last_swap_date_str = data.get('latestSimChange')

        if last_swap_date_str:
            last_swap_date = datetime.strptime(last_swap_date_str, '%Y-%m-%dT%H:%M:%S.%fZ')
            return {'last_swap_date': last_swap_date, 'error': None}
        else:
            return {'last_swap_date': None, 'error': 'No SIM swap data found.'}

    except requests.exceptions.RequestException as e:
        return {'last_swap_date': None, 'error': f'Error calling SIM Swap API: {e}'}
    except ValueError as e:
        return {'last_swap_date': None, 'error': f'Error parsing SIM Swap API response: {e}'}
