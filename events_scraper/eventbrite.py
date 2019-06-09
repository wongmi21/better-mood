import json
import logging
from datetime import datetime, timedelta

import firebase_admin
import requests
from firebase_admin import credentials, firestore

from api_scraper import ApiScraper, RequestSettings


def run(firestore_col):
    # API settings. Include api request url, headers, query
    url = "https://www.eventbriteapi.com/v3/events/search"
    query = {"q": "depression", "location.latitude": "1.3521",
             "location.longitude": "103.8198"}
    headers = {
        'Authorization': "Bearer BISAVVUFFHHMX35KQA5V",
        'User-Agent': "PostmanRuntime/7.13.0",
        'Accept': "*/*",
        'Cache-Control': "no-cache",
        'Postman-Token': "fb9c729e-01dc-44fb-b978-e79d02a8f8fd,b7598c6f-3a7e-4874-829e-675f4e6dd4ef",
        'cookie': "mgrefby=; G=v%3D2%26i%3D778f228a-5f99-4421-adbb-d38e722e015f%26a%3Db81%26s%3Dd8d1b2268330f6094913c4d4c8c00d46e8624be2; SS=AE3DLHTEFr8NftcyL4uGTRDFIc2dRafYFg; eblang=lo%3Den_US%26la%3Den-us; AS=c51bff89-68a3-4d6f-bde3-52299cddffab; mgref=typeins; SP=AGQgbbkms72lIm9VFYQtcZJWrXf6-wN66rmhYtOBDZ8pIsuVblU_o-E9OUmQI62LoSlXWB1niHBcHJnjackJ3zyJlrpE9hRsSwdfflTh6oN2YSkFDN5PiFZ3zV25boUMzDCKrTr0doTnP7C6AcfdkezqTAg9mM5ou9XTitkuRGKkhfCoOGoa_DJuFicyQgzd9XYR3chjbTBrzWUwHU_iQzFQA-uIHRTXTLwa6MELPmTybRwRX4SP-LY",
        'accept-encoding': "gzip, deflate",
        'referer': "https://www.eventbriteapi.com/v3/events/search?q=depression&location.latitude=1.3521&location.longitude=103.8198",
        'Connection': "keep-alive",
        'cache-control': "no-cache"
    }
    request_settings = RequestSettings(url, headers=headers, query=query)

    # API response entry point to list of events
    events_list_field = 'events'

    # Fields to scrape. Map firestore field name to API field name.
    def map_fields(event):
        return {
            'id': event['id'],
            'name': event['name']['text'],
            'start': {
                'datetime': datetime.strptime(event['start']['utc'], '%Y-%m-%dT%H:%M:%SZ')
            },
            'end': {
                'datetime': datetime.strptime(event['end']['utc'], '%Y-%m-%dT%H:%M:%SZ')
            },
            'url': event['url']
        }

    eventbrite_scraper = ApiScraper(
        source='eventbrite', request_settings=request_settings, events_list_field=events_list_field, map_fields=map_fields, firestore_col=firestore_col)

    eventbrite_scraper.run()
