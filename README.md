# AI Medical Assistant App

Production-oriented starter for a cross-platform Flutter app with Django REST backend and safe AI integration.

## Features

- Secure authentication (JWT)
- AI symptom checker with medical safety prompt and disclaimer
- Emergency keyword detection and alert flow
- Medication reminders with daily scheduled local notifications, edit/delete support, and taken/missed status
- Health dashboard (steps, heart rate, sleep) with charts
- Voice assistant (speech-to-text and text-to-speech)
- Light and dark themes

## Workspace Structure

- `ai_medical_assistant_app/` Flutter client
- `backend/` Django REST API

## Flutter Setup

1. Install Flutter stable and run:
   - `cd ai_medical_assistant_app`
   - `flutter pub get`
2. Copy env template:
   - `.env.example` -> `.env` (or configure constants directly)
3. Update backend base URL in `lib/core/constants/api_constants.dart` if needed.
4. Run app:
   - `flutter run`

### Flutter Build

- Android APK: `flutter build apk --release`
- iOS: `flutter build ios --release`

## Django Setup

1. Create virtualenv and install requirements:
   - `cd backend`
   - `python -m venv .venv`
   - `.venv\\Scripts\\activate` (Windows)
   - `pip install -r requirements.txt`
2. Copy env:
   - `.env.example` -> `.env`
3. Ensure PostgreSQL is running and credentials match `.env`.
4. Run migrations and server:
   - `python manage.py makemigrations`
   - `python manage.py migrate`
   - `python manage.py runserver`

## API Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/profile`
- `POST /chat/ask-ai`
- `GET/POST /medications`
- `PATCH /medications/{id}`
- `GET/POST /user/health-data/`

## AI Safety Rules

- The app never presents AI as a doctor.
- All symptom guidance includes a disclaimer.
- Emergency symptoms (`chest pain`, `can't breathe`, `severe bleeding`) trigger emergency alert and bypass AI response.

## Testing

### Flutter

- Unit test: `test/emergency_detector_test.dart`
- Widget test: `test/widget_test.dart`
- Run: `flutter test`

### Django

- Auth API tests: `accounts/tests.py`
- Chat emergency test: `chat/tests.py`
- Run: `python manage.py test`

### Continuous Integration

- GitHub Actions workflow: `.github/workflows/ci.yml`
- Runs Django migrations + tests and Flutter tests on every push/PR to `main`

## Quick Scripts (Windows PowerShell)

- Backend setup: `./scripts/setup_backend.ps1`
- Run backend: `./scripts/run_backend.ps1`
- Run Flutter app: `./scripts/run_flutter.ps1`
- Full verification (migrate + tests): `./scripts/verify_all.ps1`

## Deployment

### Backend

- Deploy Django to Render or AWS (Elastic Beanstalk/ECS) with PostgreSQL.
- Set environment variables from `.env.example`.
- Enforce HTTPS at ingress/load balancer.

### Frontend

- Distribute Android release APK/AAB.
- Build/sign iOS release in Xcode and publish via App Store Connect.

## Compliance Notes

- This app is not a medical diagnosis tool.
- Do not store sensitive health records insecurely.
- Use HTTPS and secure token storage for all authenticated traffic.
