from rest_framework import serializers


class AskAIRequestSerializer(serializers.Serializer):
    symptom_text = serializers.CharField(max_length=2000, allow_blank=False, trim_whitespace=True)


class AskAIResponseSerializer(serializers.Serializer):
    possible_causes = serializers.ListField(child=serializers.CharField(), allow_empty=False)
    urgency_level = serializers.ChoiceField(choices=("low", "medium", "high"))
    next_steps = serializers.ListField(child=serializers.CharField(), allow_empty=False)
    disclaimer = serializers.CharField(allow_blank=False)
    emergency = serializers.BooleanField()


class EmergencyResponseSerializer(serializers.Serializer):
    emergency = serializers.BooleanField()
    keywords = serializers.ListField(child=serializers.CharField(), allow_empty=False)
    message = serializers.CharField(allow_blank=False)
