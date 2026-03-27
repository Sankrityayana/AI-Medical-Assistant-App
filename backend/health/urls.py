from django.urls import path

from .views import HealthDataView

urlpatterns = [
    path("", HealthDataView.as_view(), name="health-data"),
]
