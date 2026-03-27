from rest_framework.routers import DefaultRouter

from .views import MedicationViewSet

router = DefaultRouter(trailing_slash=False)
router.register("", MedicationViewSet, basename="medication")

urlpatterns = router.urls
