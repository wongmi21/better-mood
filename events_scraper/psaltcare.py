import hashlib
import logging
import re
from datetime import datetime

import firebase_admin
import pytz
import scrapy
from firebase_admin import credentials, firestore
from scrapy.crawler import CrawlerProcess


class PsaltcareSpider(scrapy.Spider):
    name = "Psaltcare Spider"
    start_urls = (
        'https://events.time.ly/sou17vj?list_more=1&page=1&start_date=' +
        datetime.today().strftime('%Y-%m-%d') + '&view=stream',
        'https://events.time.ly/sou17vj?list_more=1&page=2&start_date=' +
        datetime.today().strftime('%Y-%m-%d') + '&view=stream',
        'https://events.time.ly/sou17vj?list_more=1&page=3&start_date=' +
        datetime.today().strftime('%Y-%m-%d') + '&view=stream',
        'https://events.time.ly/sou17vj?list_more=1&page=4&start_date=' +
        datetime.today().strftime('%Y-%m-%d') + '&view=stream',
    )

    def __init__(self, col):
        self.col = col

    def parse(self, response):
        events = response.css(
            '.timely-event')
        for event in events:
            id = event.css('::attr(data-event-full-id)').get()
            name = event.css('.timely-title-text::text').get()
            url = event.css('::attr(href)').get()
            doc = next(self.col.where('source', '==', 'psaltcare').where(
                'id', '==', id).stream(), None)
            if doc:
                logging.getLogger('psaltcare').info(name + ' - OLD')
            else:
                yield scrapy.Request(url, callback=self.parse_date)

    def parse_date(self, response):
        id = response.xpath('string(//*[@data-event-full-id]/@data-event-full-id)').get()
        name = response.css('.timely-event-title::text').get().strip()
        url = response.url
        image = response.css('.timely-featured-image::attr(src)').get()
        daterange_html = response.xpath(
            '//span[@class="timely-event-datetime"]').get()
        daterange_text = re.sub(r'<.*>', '', daterange_html).strip()
        date_text = daterange_text[:-26]
        timerange_text = daterange_text[-20:]
        starttime_text, endtime_text = timerange_text.split(' to ')
        timezone = pytz.timezone("Asia/Singapore")
        start_datetime = timezone.localize(datetime.strptime(
            date_text + ' ' + starttime_text, '%A, %B %d, %Y %I:%M %p'))
        end_datetime = timezone.localize(datetime.strptime(
            date_text + ' ' + endtime_text, '%A, %B %d, %Y %I:%M %p'))
        event = {
            'source': 'psaltcare',
            'id': id,
            'name': name,
            'url': url,
            'image': image,
            'start': {
                'datetime': start_datetime
            },
            'end': {
                'datetime': end_datetime
            }
        }
        logging.getLogger('psaltcare').info(name + ' - NEW')
        self.col.document().set(event)


def run(firestore_col):
    process = CrawlerProcess({'LOG_ENABLED': False})
    process.crawl(PsaltcareSpider, firestore_col)
    process.start()
