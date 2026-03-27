from rest_framework import serializers

from .models import Medication


class MedicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medication
        fields = ("id", "name", "dosage", "reminder_time", "is_taken", "created_at")
        read_only_fields = ("id", "created_at")
