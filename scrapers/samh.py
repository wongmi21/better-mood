import hashlib
import logging
import re
from datetime import datetime

import firebase_admin
import pytz
import scrapy
from firebase_admin import credentials, firestore
from scrapy.crawler import CrawlerProcess


class SamhSpider(scrapy.Spider):
    name = "Samh Spider"
    start_urls = [
        'https://www.samhealth.org.sg/media/calendar-of-events/'
    ]

    def __init__(self, col):
        self.col = col

    def parse(self, response):
        event_ids = response.css('.dp_daily_event::attr(data-dppec-event)').extract()
        dates = response.css('.dp_daily_event::attr(data-dppec-date)').extract()
        times = response.css('.dp_daily_event > strong::text').extract()
        for i in range(len(event_ids)):
            event_id = event_ids[i]
            date = dates[i]
            time = times[i]
            yield scrapy.Request(url='https://www.samhealth.org.sg/client/samhealth/wp-admin/admin-ajax.php',
                                 method='POST',
                                 headers={'Content-Type': "application/x-www-form-urlencoded"},
                                 body='event=' + event_id + '&calendar=1date=' + date + '&action=getEvent',
                                 callback=self.parse_items,
                                 meta={'id': event_id + '_' + date, 'date': date, 'time': time})

    def parse_items(self, response):
        id = response.meta.get('id')
        date = response.meta.get('date')
        time = response.meta.get('time')
        ids = response.css('.dp_pec_event_title_sp::text').extract()
        names = response.css('.dp_pec_event_title_sp::text').extract()
        for i in range(len(ids)):
            time_range = time.split(' - ')
            timezone = pytz.timezone("Asia/Singapore")
            event = {
                'source': 'samh',
                'id': ids[i],
                'name': names[i],
                'start': {'datetime': timezone.localize(datetime.strptime(date + ' ' + time_range[0], '%Y-%m-%d %I:%M %p'))},
                'end': {'datetime': timezone.localize(datetime.strptime(date + ' ' + time_range[1], '%Y-%m-%d %I:%M %p'))},
                'url': 'https://www.samhealth.org.sg/media/calendar-of-events/'
            }
            self.col.document().set(event)


def run(firestore_col):
    process = CrawlerProcess({'LOG_ENABLED': False})
    process.crawl(SamhSpider, firestore_col)
    process.start()
