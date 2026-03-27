from rest_framework import serializers

from .models import HealthData


class HealthDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthData
        fields = ("steps", "heart_rate", "sleep_hours", "updated_at")
        read_only_fields = ("updated_at",)
