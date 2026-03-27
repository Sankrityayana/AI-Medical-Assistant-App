import json

from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .serializers import AskAIRequestSerializer, AskAIResponseSerializer, EmergencyResponseSerializer
from .services import EMERGENCY_KEYWORDS, ask_ai, has_emergency_signal, normalize_ai_payload


class AskAIView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    throttle_scope = "chat_ai"

    def post(self, request):
        request_serializer = AskAIRequestSerializer(data=request.data)
        request_serializer.is_valid(raise_exception=True)
        symptom_text = request_serializer.validated_data["symptom_text"]

        if has_emergency_signal(symptom_text):
            emergency_payload = {
                "emergency": True,
                "keywords": EMERGENCY_KEYWORDS,
                "message": "Potential emergency detected. Please call your local emergency number immediately.",
            }
            response_serializer = EmergencyResponseSerializer(data=emergency_payload)
            response_serializer.is_valid(raise_exception=True)
            return Response(response_serializer.validated_data, status=status.HTTP_200_OK)

        ai_result = ask_ai(symptom_text)
        raw = ai_result.get("raw", "{}")
        fallback = ai_result.get("fallback", {})
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = fallback

        safe_payload = normalize_ai_payload(parsed if isinstance(parsed, dict) else fallback)
        safe_payload["emergency"] = False

        response_serializer = AskAIResponseSerializer(data=safe_payload)
        response_serializer.is_valid(raise_exception=True)
        return Response(response_serializer.validated_data)
