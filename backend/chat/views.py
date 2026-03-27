import json

from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import EMERGENCY_KEYWORDS, ask_ai, has_emergency_signal, normalize_ai_payload


class AskAIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        symptom_text = request.data.get("symptom_text", "").strip()
        if not symptom_text:
            return Response({"detail": "symptom_text is required."}, status=status.HTTP_400_BAD_REQUEST)

        if has_emergency_signal(symptom_text):
            return Response(
                {
                    "emergency": True,
                    "keywords": EMERGENCY_KEYWORDS,
                    "message": "Potential emergency detected. Please call your local emergency number immediately.",
                },
                status=status.HTTP_200_OK,
            )

        ai_result = ask_ai(symptom_text)
        raw = ai_result.get("raw", "{}")
        fallback = ai_result.get("fallback", {})
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = fallback

        safe_payload = normalize_ai_payload(parsed if isinstance(parsed, dict) else fallback)
        safe_payload["emergency"] = False
        return Response(safe_payload)
