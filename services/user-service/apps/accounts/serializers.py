from rest_framework import serializers
from apps.accounts import models as accounts_models




class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = accounts_models.User
        fields = "__all__"
        read_only_fields = ("id", "is_active", "is_staff")
