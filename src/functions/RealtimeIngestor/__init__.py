import logging
import os
import requests
import json
import azure.functions as func
from azure.eventhub import EventHubProducerClient, EventData

DE_LIJN_API_KEY = os.environ["DE_LIJN_API_KEY_REALTIME"]
REALTIME_API_URL = os.environ["REALTIME_API_URL"]
EVENT_HUB_CONNECTION_STR = os.environ["EVENT_HUB_CONNECTION_STRING"]
EVENT_HUB_NAME = os.environ["EVENT_HUB_NAME"]

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function: fetching real-time data...')

    try:
        headers = {"Ocp-Apim-Subscription-Key": DE_LIJN_API_KEY}
        response = requests.get(REALTIME_API_URL, headers=headers)
        response.raise_for_status() 

        all_entities = response.json().get('entity', [])

        if not all_entities:
            logging.warning("API call successful but returned no vehicle entities.")
            return func.HttpResponse("API returned no data.", status_code=200)

    except requests.exceptions.RequestException as e:
        logging.error(f"Error calling De Lijn API: {e}")
        return func.HttpResponse("Error calling external API.", status_code=502)
    
    producer = EventHubProducerClient.from_connection_string(
        conn_str=EVENT_HUB_CONNECTION_STR,
        eventhub_name=EVENT_HUB_NAME
    )

    logging.info(f"De-batching {len(all_entities)} entities into individual events.")
    
    try:
        event_data_batch = producer.create_batch()

        for entity_data in all_entities:
            event_body = json.dumps(entity_data)
            
            try:
                event_data_batch.add(EventData(event_body))
            except ValueError:
                # The batch is full. Send it.
                producer.send_batch(event_data_batch)
                
                # Create new & add current event
                event_data_batch = producer.create_batch()
                event_data_batch.add(EventData(event_body))

        # Send any remaining
        if len(event_data_batch) > 0:
            producer.send_batch(event_data_batch)
            
    except Exception as e:
        logging.error(f"An unexpected error occurred while sending to Event Hub: {e}")
        return func.HttpResponse("An internal error occurred during event sending.", status_code=500)

    finally:
        producer.close()

    success_message = f"Successfully processed and sent {len(all_entities)} events to Event Hub."
    logging.info(success_message)
    return func.HttpResponse(success_message, status_code=200)