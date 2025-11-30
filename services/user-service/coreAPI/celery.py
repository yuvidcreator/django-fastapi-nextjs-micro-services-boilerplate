import os
# from __future__ import absolute_import
from celery import Celery
from celery.schedules import crontab

from coreAPI.settings import base

# Set the default Django settings module for the 'celery' program.
if base.env("DEV_PHASE")=="prod":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "coreAPI.settings.production")
else:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "coreAPI.settings.development")


app = Celery("coreAPI")
app.conf.enable_utc = True

app.config_from_object("django.conf:settings", namespace="CELERY")

# app.autodiscover_tasks()
app.autodiscover_tasks(lambda: base.INSTALLED_APPS)
