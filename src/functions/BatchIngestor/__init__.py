import logging
import os
import requests
from datetime import datetime, timezone
import azure.functions as func
from azure.storage.blob import BlobServiceClient

ADLS_CONNECTION_STRING = os.environ["ADLS_CONNECTION_STRING"]
DE_LIJN_API_KEY_STATIC = os.environ["DE_LIJN_API_KEY_STATIC"]
STATIC_GTFS_API_URL = os.environ["STATIC_GTFS_API_URL"]
BRONZE_CONTAINER_NAME = os.environ["BRONZE_CONTAINER_NAME"]

def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = datetime.now(timezone.utc)
    
    if mytimer.past_due:
        logging.info('The timer is past due!')

    logging.info(f'Python timer trigger function started execution at {utc_timestamp.isoformat()}')

    try:
        # Fetch GTFS data
        logging.info(f"Fetching De Lijn static GTFS API at {STATIC_GTFS_API_URL}...")
        headers = {"Ocp-Apim-Subscription-Key": DE_LIJN_API_KEY_STATIC}
        response = requests.get(STATIC_GTFS_API_URL, headers=headers)
        response.raise_for_status()
        gtfs_data = response.content
        logging.info("Successfully downloaded GTFS data.")

        # Upload to ADLS Gen 2
        today_str = utc_timestamp.strftime('%Y-%m-%d')
        blob_name = f"gtfs/{today_str}/gtfs_transit.zip"

        blob_service_client = BlobServiceClient.from_connection_string(ADLS_CONNECTION_STRING)
        blob_client = blob_service_client.get_blob_client(container=BRONZE_CONTAINER_NAME, blob=blob_name)

        logging.info(f"Uploading data to ADLS at: {BRONZE_CONTAINER_NAME}/{blob_name}")
        blob_client.upload_blob(gtfs_data, overwrite=True)
        logging.info("Upload successful.")

    except requests.exceptions.RequestException as e:
        logging.error(f"Error calling De Lijn API: {e}")
        raise
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        raise

    logging.info(f'Python timer trigger function finished execution at {datetime.now(timezone.utc).isoformat()}')