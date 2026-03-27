# AI Medical Assistant App

Production-oriented starter for a cross-platform Flutter app with a Django REST backend and safety-first AI symptom guidance.

## What This Includes

- JWT authentication and profile endpoints
- AI symptom checker with strict non-diagnostic disclaimer behavior
- Emergency signal detection that bypasses AI and prompts urgent action
- Medication reminders with daily local notification scheduling
- Health dashboard with charted vitals and habits
- Voice input/output flows for accessibility
- Windows PowerShell automation scripts for setup, run, and verification

## Repository Structure

- `ai_medical_assistant_app/` Flutter client
- `backend/` Django REST API
- `scripts/` PowerShell automation helpers

## Quick Start (Windows)

1. Backend setup:
   - `./scripts/setup_backend.ps1`
2. Run backend:
   - `./scripts/run_backend.ps1`
3. Run Flutter app:
   - `./scripts/run_flutter.ps1`
4. Full verification (backend migrate/tests + Flutter tests):
   - `./scripts/verify_all.ps1`

## Manual Setup

### Flutter

1. `cd ai_medical_assistant_app`
2. `flutter pub get`
3. Update backend base URL in `lib/core/constants/api_constants.dart` if needed.
4. `flutter run`

Build commands:

- Android: `flutter build apk --release`
- iOS: `flutter build ios --release`

### Django

1. `cd backend`
2. `python -m venv .venv`
3. `.venv\\Scripts\\activate` (Windows)
4. `pip install -r requirements.txt`
5. Copy `.env.example` to `.env`
6. `python manage.py migrate`
7. `python manage.py runserver`

## Environment Configuration

Core backend variables:

- `DJANGO_SECRET_KEY`: set to a long random value (32+ chars recommended)
- `DEBUG`: `True` for local only
- `ALLOWED_HOSTS`: comma-separated hosts
- `OPENAI_API_KEY`: OpenAI API key
- `OPENAI_MODEL`: default `gpt-4o-mini`
- `OPENAI_TIMEOUT_SECONDS`: AI request timeout (default `20`)
- `OPENAI_MAX_RETRIES`: AI retry count (default `3`)
- `CHAT_AI_RATE_LIMIT`: scoped throttle for symptom endpoint (default `20/minute`)

Database selection behavior:

- `USE_SQLITE=True` forces SQLite regardless of PostgreSQL variables
- If `USE_SQLITE` is not true and `POSTGRES_DB` is set, PostgreSQL is used
- If neither applies, SQLite is used by default

PostgreSQL variables (only when using Postgres):

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`

## API Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/profile`
- `POST /chat/ask-ai`
- `GET/POST /medications`
- `PATCH /medications/{id}`
- `GET/POST /user/health-data/`

## Testing and CI

Local tests:

- Backend: `python manage.py test`
- Flutter: `flutter test`

Notes about `verify_all.ps1`:

- Runs with fail-fast command checks
- Forces SQLite (`USE_SQLITE=True`) for deterministic local verification
- Uses a strong temporary secret key value during verification to avoid weak-key JWT warnings

CI:

- Workflow: `.github/workflows/ci.yml`
- Runs backend migration/tests and Flutter tests on pushes and pull requests

## AI Safety Rules

- The assistant does not provide medical diagnosis
- Every symptom response includes a disclaimer
- Emergency phrases such as `chest pain`, `can't breathe`, and `severe bleeding` trigger emergency handling instead of AI triage

## Deployment Notes

Backend:

- Deploy on Render, Azure, or AWS with PostgreSQL for production
- Set production environment variables explicitly
- Enforce HTTPS and secure host/CORS settings

Frontend:

- Build and sign Android APK/AAB
- Build/sign iOS release via Xcode and publish through App Store Connect

## Compliance Reminder

- This app is not a medical diagnosis tool
- Store health data securely
- Use HTTPS and secure token storage for authenticated traffic
