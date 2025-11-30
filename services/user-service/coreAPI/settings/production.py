from .base import *

# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

if env("ENVIRONMENT") == "docker":
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": env("POSTGRES_DB", default="socialx_db"),
            "USER": env("POSTGRES_USER", default="socialx"),
            "PASSWORD": env("POSTGRES_PASSWORD", default="change_me"),
            "HOST": env("POSTGRES_HOST", default="localhost"),
            "PORT": env.int("POSTGRES_PORT", default=5432),
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }


SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

