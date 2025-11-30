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

## =========== or ===================
# Parse database connection url strings
# like psql://user:pass@127.0.0.1:8458/db
# DATABASES = {
#     # read os.environ['DATABASE_URL'] and raises
#     # ImproperlyConfigured exception if not found
#     #
#     # The db() method is an alias for db_url().
#     'default': env.db(),

#     # read os.environ['SQLITE_URL']
#     'extra': env.db_url(
#         'SQLITE_URL',
#         default='sqlite:////tmp/my-tmp-sqlite.db'
#     )
# }