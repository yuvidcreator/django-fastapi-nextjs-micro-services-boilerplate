from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.response import Response

class UserService:

    @staticmethod
    def user_login(payload):
        obj = None
        if payload:
            email = payload.data.get("email")
            password = payload.data.get("password")
            obj = authenticate(payload, email=email, password=password)
        return obj
    
    @staticmethod
    def process_tokens(user):
        response = None
        if user:
            try:
                refresh = RefreshToken.for_user(user)
                access_token = str(refresh.access_token)
                refresh_token = str(refresh)

                # Set cookies
                cookie_params = {
                    "httponly": settings.SIMPLE_JWT.get("AUTH_COOKIE_HTTP_ONLY", True),
                    "secure": settings.SIMPLE_JWT.get("AUTH_COOKIE_SECURE", False),
                    "samesite": settings.SIMPLE_JWT.get("AUTH_COOKIE_SAMESITE", "Lax"),
                    "path": "/",
                }
                response = Response({"detail": "Login successful"})
                response.set_cookie(settings.SIMPLE_JWT.get("AUTH_COOKIE", "access_token"), access_token, **cookie_params)
                response.set_cookie("refresh_token", refresh_token, **cookie_params)
            except Exception as e:
                print(f"Error while processing : {e}")
                return e
        else:
            return response
