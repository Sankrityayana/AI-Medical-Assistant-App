from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import HealthData
from .serializers import HealthDataSerializer


class HealthDataView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        health_data, _ = HealthData.objects.get_or_create(user=request.user)
        return Response(HealthDataSerializer(health_data).data)

    def post(self, request):
        health_data, _ = HealthData.objects.get_or_create(user=request.user)
        serializer = HealthDataSerializer(health_data, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
