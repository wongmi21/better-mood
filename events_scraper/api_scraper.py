import json
import logging

import requests


class RequestSettings():
    def __init__(self, url, **kwargs):
        self.url = url
        self.headers = kwargs.get('headers', None)
        self.query = kwargs.get('query', None)

    def response(self):
        return requests.request(
            "GET", self.url, headers=self.headers, params=self.query)


class ApiScraper():
    def __init__(self, source, request_settings, events_list_field, map_fields, firestore_col):
        self.source = source
        self.request_settings = request_settings
        self.events_list_field = events_list_field
        self.map_fields = map_fields
        self.firestore_col = firestore_col

    def run(self):
        response = self.request_settings.response()
        events = json.loads(response.text)[self.events_list_field]
        for event in events:
            map_fields = self.map_fields(event)
            id = map_fields['id']
            doc = next(self.firestore_col.where('source', '==', self.source).where(
                'id', '==', id).stream(), None)
            if doc:
                logging.getLogger(self.source).info(map_fields['name'] + ' - OLD')
            else:
                map_fields['source'] = self.source
                self.firestore_col.document().set(map_fields)
                logging.getLogger(self.source).info(map_fields['name'] + ' - NEW')
