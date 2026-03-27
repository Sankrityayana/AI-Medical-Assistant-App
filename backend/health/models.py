from django.conf import settings
from django.db import models


class HealthData(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="health_data")
    steps = models.IntegerField(default=0)
    heart_rate = models.IntegerField(default=0)
    sleep_hours = models.FloatField(default=0)
    updated_at = models.DateTimeField(auto_now=True)
