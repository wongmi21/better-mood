import logging
from datetime import datetime, timedelta

import dateutil.parser
import firebase_admin
from firebase_admin import credentials, firestore

from api_scraper import ApiScraper, RequestSettings


def run(firestore_col):
    # API settings. Include api request url, headers, query
    date_min = str(datetime.now().date() - timedelta(days=30))
    date_max = str(datetime.now().date() + timedelta(days=365))
    url = "https://clients6.google.com/calendar/v3/calendars/clubheal7@gmail.com/events?calendarId=clubheal7%40gmail.com&singleEvents=true&maxResults=1000&key=AIzaSyBNlYH01_9Hc5S1J9vuFmu2nUqBZJNAXxs&timeMin=" + date_min + "T00%3A00%3A00%2B08%3A00&timeMax=" + date_max + "T00%3A00%3A00%2B08%3A00"
    request_settings = RequestSettings(url)

    # API response entry point to list of events
    events_list_field = 'items'

    # Fields to scrape. Map firestore field name to API field name.
    def map_fields(event):
        start_date = 'date' in event['start']
        end_date = 'date' in event['end']
        start_datetime = 'dateTime' in event['start']
        end_datetime = 'dateTime' in event['end']
        return {
            'id': event['id'],
            'name': event['summary'],
            'start': {
                'date': datetime.strptime(event['start']['date'], '%Y-%m-%d') if start_date else None,
                'datetime': dateutil.parser.parse(event['start']['dateTime']) if start_datetime else None
            },
            'end': {
                'date': datetime.strptime(event['end']['date'], '%Y-%m-%d') if end_date else None,
                'datetime': dateutil.parser.parse(event['end']['dateTime']) if end_datetime else None
            },
            'url': event['htmlLink']
        }

    meetup_scraper = ApiScraper(
        source='clubheal', request_settings=request_settings, events_list_field=events_list_field, map_fields=map_fields, firestore_col=firestore_col)

    meetup_scraper.run()
