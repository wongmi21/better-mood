import hashlib
import logging
from datetime import datetime

import firebase_admin
import pytz
import scrapy
from firebase_admin import credentials, firestore
from scrapy.crawler import CrawlerProcess


class ImhSpider(scrapy.Spider):
    name = "IMH Spider",
    start_urls = (
        'https://www.imh.com.sg/events/',
    )

    def __init__(self, col):
        self.col = col

    def parse(self, response):
        rows = response.css(
            '#ctl00_cphMain_ctlEventList_pnlList tr:not(:first-child)')
        links = []
        for row in rows:
            links.append(row.css('td:nth-child(1) > a::attr(href)').get())
        for link in links:
            yield response.follow(link, self.parse_event_page)

    def parse_event_page(self, response):
        name = response.css('div.content h2::text').get()
        event_date = response.css(
            '.datatable2 tr:nth-child(1) > td::text').get()
        time = response.css('.datatable2 tr:nth-child(2) > td::text').get()
        timezone = pytz.timezone("Asia/Singapore")
        start_datetime = timezone.localize(datetime.strptime(
            event_date + ' ' + time.split(' - ')[0], '%d %b %Y %I.%M%p'))
        end_datetime = timezone.localize(datetime.strptime(
            event_date + ' ' + time.split(' - ')[1], '%d %b %Y %I.%M%p'))
        id = hashlib.sha1(
            (name + event_date + time).encode('UTF-8')).hexdigest()[:10]
        event = {
            'source': 'imh',
            'id': id,
            'name': name,
            'start': {
                'datetime': start_datetime
            },
            'end': {
                'datetime': end_datetime
            },
            'url': response.url,
        }
        doc = next(self.col.where('source', '==', 'imh').where(
            'id', '==', id).stream(), None)
        if doc:
            logging.getLogger('imh').info(event['name'] + ' - OLD')
        else:
            self.col.document().set(event)
            logging.getLogger('imh').info(event['name'] + ' - NEW')


def run(firestore_col):
    process = CrawlerProcess({'LOG_ENABLED': False})
    process.crawl(ImhSpider, firestore_col)
    process.start()
