from rest_framework import permissions, viewsets

from .models import Medication
from .serializers import MedicationSerializer


class MedicationViewSet(viewsets.ModelViewSet):
    serializer_class = MedicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Medication.objects.filter(user=self.request.user).order_by("reminder_time")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
