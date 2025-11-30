import pytest
from django.contrib.auth import get_user_model
User = get_user_model()

@pytest.mark.django_db
def test_create_user():
    u = User.objects.create_user(email="test@example.com", password="pass1234")
    assert u.email == "test@example.com"
    assert u.check_password("pass1234")
