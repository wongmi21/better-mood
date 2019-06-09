import json
import logging
from datetime import datetime, timedelta
from multiprocessing import Process

import firebase_admin
import requests

import clubheal
import eventbrite
import imh
import meetup
import psaltcare
import samh

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='[%(name)s] %(message)s')
    loggers = [logging.getLogger(logger_name)
               for logger_name in logging.root.manager.loggerDict]
    for logger in loggers:
        logger.setLevel(logging.WARNING)
        logger.propagate = False

    firebase_app = firebase_admin.initialize_app()
    firestore = firebase_admin.firestore.client(firebase_app)
    firestore_col = firestore.collection('events')

    meetup_scraper = Process(target=meetup.run, args=(firestore_col, ))
    eventbrite_scraper = Process(target=eventbrite.run, args=(firestore_col, ))
    imh_scraper = Process(target=imh.run, args=(firestore_col, ))
    clubheal_scraper = Process(target=clubheal.run, args=(firestore_col, ))
    psaltcare_scraper = Process(target=psaltcare.run, args=(firestore_col, ))
    samh_scraper = Process(target=samh.run, args=(firestore_col, ))

    meetup_scraper.start()
    eventbrite_scraper.start()
    imh_scraper.start()
    clubheal_scraper.start()
    psaltcare_scraper.start()
    samh_scraper.start()
