"""
ASGI config for coreAPI project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os
from coreAPI.settings import base

from django.core.asgi import get_asgi_application

if base.env("DEV_PHASE")=="prod":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "coreAPI.settings.production")
else:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "coreAPI.settings.development")

application = get_asgi_application()
