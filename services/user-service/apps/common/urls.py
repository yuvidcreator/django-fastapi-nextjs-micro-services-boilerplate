from django.urls import path
from apps.common import views


urlpatterns = [
    path("contact/", views.CreateEnquiriesAPIView.as_view(), name="enquiry"),
]