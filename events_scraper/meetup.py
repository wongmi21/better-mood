import logging
from datetime import date, datetime, timedelta

import firebase_admin
from firebase_admin import credentials, firestore

from api_scraper import ApiScraper, RequestSettings


def run(firestore_col):
    # API settings. Include api request url, headers, query
    url = "https://api.meetup.com/find/upcoming_events?key=3642e20123287328574f3a70406f50"
    query = {"lat": "1.3521", "lon": "103.8198",
             "radius": "20", "text": "depression", "order": "time"}
    request_settings = RequestSettings(url, query=query)

    # API response entry point to list of events
    events_list_field = 'events'

    # Fields to scrape. Map firestore field name to API field name.
    def map_fields(event):
        utc_offset = timedelta(milliseconds=event['utc_offset'])
        start_datetime = datetime.strptime(
            event['local_date'] + ' ' + event['local_time'], '%Y-%m-%d %H:%M') - utc_offset
        end_datetime = start_datetime + \
            timedelta(milliseconds=event['duration'])
        return {
            'id': event['id'],
            'name': event['name'],
            'start': {
                'datetime': start_datetime,
            },
            'end': {
                'datetime': end_datetime,
            },
            'url': event['link']
        }

    meetup_scraper = ApiScraper(
        source='meetup', request_settings=request_settings, events_list_field=events_list_field, map_fields=map_fields, firestore_col=firestore_col)

    meetup_scraper.run()
