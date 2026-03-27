from django.conf import settings
from openai import OpenAI

EMERGENCY_KEYWORDS = ["chest pain", "can't breathe", "severe bleeding"]

SAFETY_PROMPT = (
    "You are a medical assistant AI. Provide general health guidance based on symptoms. "
    "Do NOT diagnose. Always include a disclaimer suggesting consulting a doctor. "
    "Respond in strict JSON with keys: possible_causes (array of strings), urgency_level "
    "(one of low, medium, high), next_steps (array of strings), disclaimer (string)."
)


def has_emergency_signal(text: str) -> bool:
    lowered = text.lower()
    return any(keyword in lowered for keyword in EMERGENCY_KEYWORDS)


def ask_ai(symptom_text: str) -> dict:
    client = OpenAI(api_key=settings.OPENAI_API_KEY)
    completion = client.chat.completions.create(
        model=settings.OPENAI_MODEL,
        temperature=0.2,
        messages=[
            {"role": "system", "content": SAFETY_PROMPT},
            {"role": "user", "content": symptom_text},
        ],
    )
    content = completion.choices[0].message.content or "{}"
    return {"raw": content}
