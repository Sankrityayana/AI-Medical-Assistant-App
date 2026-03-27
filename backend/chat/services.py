import logging
import time

from django.conf import settings
from openai import APIConnectionError, APITimeoutError, OpenAI, RateLimitError

logger = logging.getLogger(__name__)

EMERGENCY_KEYWORDS = ["chest pain", "can't breathe", "severe bleeding"]

SAFETY_PROMPT = (
    "You are a medical assistant AI. Provide general health guidance based on symptoms. "
    "Do NOT diagnose. Always include a disclaimer suggesting consulting a doctor. "
    "Respond in strict JSON with keys: possible_causes (array of strings), urgency_level "
    "(one of low, medium, high), next_steps (array of strings), disclaimer (string)."
)

DEFAULT_DISCLAIMER = "This app is not a medical diagnosis tool. Please consult a licensed doctor."


def _sanitize_string_list(value, fallback):
    if isinstance(value, list):
        cleaned = [str(item).strip() for item in value if str(item).strip()]
        if cleaned:
            return cleaned
    return fallback


def normalize_ai_payload(payload: dict) -> dict:
    possible_causes = _sanitize_string_list(
        payload.get("possible_causes"),
        ["Could not confidently identify possible causes from the provided symptoms."],
    )
    next_steps = _sanitize_string_list(
        payload.get("next_steps"),
        ["Consult a licensed doctor for a professional evaluation."],
    )

    urgency = str(payload.get("urgency_level", "medium")).strip().lower()
    if urgency not in {"low", "medium", "high"}:
        urgency = "medium"

    disclaimer = str(payload.get("disclaimer", "")).strip() or DEFAULT_DISCLAIMER

    return {
        "possible_causes": possible_causes,
        "urgency_level": urgency,
        "next_steps": next_steps,
        "disclaimer": disclaimer,
    }


def has_emergency_signal(text: str) -> bool:
    lowered = text.lower()
    return any(keyword in lowered for keyword in EMERGENCY_KEYWORDS)


def ask_ai(symptom_text: str) -> dict:
    if not settings.OPENAI_API_KEY:
        return {
            "raw": "{}",
            "fallback": {
                "possible_causes": ["AI service is not configured."],
                "urgency_level": "medium",
                "next_steps": ["Configure OPENAI_API_KEY in backend environment settings."],
                "disclaimer": DEFAULT_DISCLAIMER,
            },
        }

    client = OpenAI(api_key=settings.OPENAI_API_KEY)
    fallback = normalize_ai_payload({})
    max_retries = max(settings.OPENAI_MAX_RETRIES, 1)

    for attempt in range(1, max_retries + 1):
        try:
            completion = client.chat.completions.create(
                model=settings.OPENAI_MODEL,
                temperature=0.2,
                timeout=settings.OPENAI_TIMEOUT_SECONDS,
                messages=[
                    {"role": "system", "content": SAFETY_PROMPT},
                    {"role": "user", "content": symptom_text},
                ],
            )
            content = completion.choices[0].message.content or "{}"
            return {"raw": content, "fallback": fallback}
        except (APITimeoutError, APIConnectionError, RateLimitError) as exc:
            logger.warning("OpenAI transient failure on attempt %s/%s: %s", attempt, max_retries, exc)
            if attempt >= max_retries:
                logger.exception("OpenAI call failed after retries")
                return {
                    "raw": "{}",
                    "fallback": {
                        "possible_causes": ["AI service is temporarily unavailable."],
                        "urgency_level": "medium",
                        "next_steps": ["Please try again shortly or consult a doctor if symptoms worsen."],
                        "disclaimer": DEFAULT_DISCLAIMER,
                    },
                }
            time.sleep(min(2 ** (attempt - 1), 4))
        except Exception:
            logger.exception("Unexpected OpenAI failure")
            return {
                "raw": "{}",
                "fallback": {
                    "possible_causes": ["Unable to process your request at the moment."],
                    "urgency_level": "medium",
                    "next_steps": ["Consult a licensed doctor for further guidance."],
                    "disclaimer": DEFAULT_DISCLAIMER,
                },
            }

    return {"raw": "{}", "fallback": fallback}
