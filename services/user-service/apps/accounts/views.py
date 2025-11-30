from django.conf import settings
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts import (
    models as accounts_models,
    serializers as accounts_serializers,
    service as accounts_services
)

class UserViewSet(viewsets.ModelViewSet):
    queryset = accounts_models.User.objects.all().order_by("id")
    serializer_class = accounts_serializers.UserSerializer

    @action(detail=False, methods=["post"], permission_classes=[AllowAny])
    def login(self, request):
        """
        Login using email + password. Returns tokens in httpOnly cookies.
        """

        user = accounts_services.UserService.user_login(payload = request)

        if user is None:
            return Response({"detail": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
        
        # refresh = RefreshToken.for_user(user)
        # access_token = str(refresh.access_token)
        # refresh_token = str(refresh)

        # # Set cookies
        # cookie_params = {
        #     "httponly": settings.SIMPLE_JWT.get("AUTH_COOKIE_HTTP_ONLY", True),
        #     "secure": settings.SIMPLE_JWT.get("AUTH_COOKIE_SECURE", False),
        #     "samesite": settings.SIMPLE_JWT.get("AUTH_COOKIE_SAMESITE", "Lax"),
        #     "path": "/",
        # }
        # response = Response({"detail": "Login successful"})
        # response.set_cookie(settings.SIMPLE_JWT.get("AUTH_COOKIE", "access_token"), access_token, **cookie_params)
        # response.set_cookie("refresh_token", refresh_token, **cookie_params)

        response = accounts_services.UserService.process_tokens(user = user)
        if response is None:
            return {
                "message": response,
                "status": status.HTTP_400_BAD_REQUEST
            }
        return response

    @action(detail=False, methods=["post"], permission_classes=[AllowAny])
    def logout(self, request):
        response = Response({"detail": "Logged out"})
        # Delete cookies
        response.delete_cookie(settings.SIMPLE_JWT.get("AUTH_COOKIE", "access_token"), path="/")
        response.delete_cookie("refresh_token", path="/")
        return response
