from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("auth/", include("accounts.urls")),
    path("chat/", include("chat.urls")),
    path("medications/", include("medications.urls")),
    path("user/health-data/", include("health.urls")),
]
