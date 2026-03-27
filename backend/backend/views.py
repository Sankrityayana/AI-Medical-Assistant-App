from django.http import JsonResponse


def root_view(request):
    return JsonResponse(
        {
            "status": "ok",
            "service": "ai-medical-assistant-backend",
            "docs": "/docs",
        }
    )


def docs_view(request):
    return JsonResponse(
        {
            "title": "AI Medical Assistant API",
            "endpoints": {
                "admin": "/admin/",
                "auth": {
                    "register": "/auth/register",
                    "login": "/auth/login",
                    "profile": "/auth/profile",
                },
                "chat": {"ask_ai": "/chat/ask-ai"},
                "medications": "/medications/",
                "health_data": "/user/health-data/",
            },
            "notes": [
                "Most endpoints require JWT authentication.",
                "Use /auth/login to obtain access and refresh tokens.",
            ],
        }
    )
