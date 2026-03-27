from django.contrib import admin
from django.urls import include, path

from .views import docs_view, root_view

urlpatterns = [
    path("", root_view, name="root"),
    path("docs", docs_view, name="docs"),
    path("admin/", admin.site.urls),
    path("auth/", include("accounts.urls")),
    path("chat/", include("chat.urls")),
    path("medications/", include("medications.urls")),
    path("user/health-data/", include("health.urls")),
]
