import logging
import os
import requests
import json
import azure.functions as func

DE_LIJN_API_KEY = os.environ["DE_LIJN_API_KEY_REALTIME"]
REALTIME_API_URL = "https://api.delijn.be/gtfs/v3/realtime?json=true"

def main(req: func.HttpRequest, eventHubMessage: func.Out[str]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function: fetching real-time data...')

    try:
        headers = {"Ocp-Apim-Subscription-Key": DE_LIJN_API_KEY}
        response = requests.get(REALTIME_API_URL, headers=headers)
        response.raise_for_status() 

        data = response.json()

        eventHubMessage.set(json.dumps(data))

        return func.HttpResponse("Successfully fetched data and sent to Event Hub.", status_code=200)

    except requests.exceptions.RequestException as e:
        logging.error(f"Error calling De Lijn API: {e}")
        return func.HttpResponse("Error calling external API.", status_code=500)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        return func.HttpResponse("An internal error occurred.", status_code=500)