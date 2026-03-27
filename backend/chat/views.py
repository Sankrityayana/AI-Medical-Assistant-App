import json

from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import EMERGENCY_KEYWORDS, ask_ai, has_emergency_signal


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
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = {
                "possible_causes": ["Unable to parse AI output."],
                "urgency_level": "medium",
                "next_steps": ["Consult a doctor for proper evaluation."],
                "disclaimer": "This app is not a medical diagnosis tool.",
            }

        parsed.setdefault("disclaimer", "This app is not a medical diagnosis tool.")
        parsed["emergency"] = False
        return Response(parsed)
