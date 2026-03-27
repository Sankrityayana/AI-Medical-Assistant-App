from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken


class ChatTests(APITestCase):
    def setUp(self):
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
