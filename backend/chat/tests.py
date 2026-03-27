from django.contrib.auth.models import User
from django.core.cache import cache
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken
from unittest.mock import patch

from chat.services import ask_ai


class ChatTests(APITestCase):
    def setUp(self):
        cache.clear()
        self.user = User.objects.create_user(username="chatuser", password="securePass123")
        token = RefreshToken.for_user(self.user).access_token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def test_emergency_detection_returns_alert(self):
        response = self.client.post(
            reverse("ask-ai"),
            {"symptom_text": "I have chest pain and feel dizzy"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get("emergency"))
        self.assertIn("message", response.data)

    def test_symptom_text_required(self):
        response = self.client.post(
            reverse("ask-ai"),
            {"symptom_text": ""},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    @patch("chat.views.ask_ai")
    def test_ai_payload_is_normalized(self, mock_ask_ai):
        mock_ask_ai.return_value = {
            "raw": '{"possible_causes": ["Migraine"], "urgency_level": "invalid", "next_steps": ["Rest"]}',
            "fallback": {},
        }

        response = self.client.post(
            reverse("ask-ai"),
            {"symptom_text": "I have a headache"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["urgency_level"], "medium")
        self.assertIn("disclaimer", response.data)
        self.assertFalse(response.data["emergency"])

    @patch("chat.views.ask_ai")
    def test_chat_endpoint_is_rate_limited(self, mock_ask_ai):
        mock_ask_ai.return_value = {
            "raw": '{"possible_causes": ["Migraine"], "urgency_level": "low", "next_steps": ["Hydrate"], "disclaimer": "This app is not a medical diagnosis tool."}',
            "fallback": {},
        }

        payload = {"symptom_text": "headache and tiredness"}
        final_status_code = status.HTTP_200_OK
        for _ in range(25):
            response = self.client.post(reverse("ask-ai"), payload, format="json")
            final_status_code = response.status_code
            if final_status_code == status.HTTP_429_TOO_MANY_REQUESTS:
                break

        self.assertEqual(final_status_code, status.HTTP_429_TOO_MANY_REQUESTS)


class ChatServiceTests(APITestCase):
    @patch("chat.services.OpenAI")
    @patch("chat.services.settings.OPENAI_API_KEY", "configured-key")
    @patch("chat.services.settings.OPENAI_MAX_RETRIES", 2)
    @patch("chat.services.settings.OPENAI_TIMEOUT_SECONDS", 0.1)
    def test_ask_ai_returns_fallback_on_transient_failures(self, mock_openai):
        client = mock_openai.return_value
        client.chat.completions.create.side_effect = Exception("boom")

        result = ask_ai("headache")

        self.assertIn("fallback", result)
        self.assertEqual(result["raw"], "{}")
        self.assertIn("possible_causes", result["fallback"])
