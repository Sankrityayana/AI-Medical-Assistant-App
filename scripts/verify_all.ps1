$ErrorActionPreference = "Stop"

Write-Host "Running backend checks..."
Set-Location "$PSScriptRoot\..\backend"
if (Test-Path ".venv\Scripts\python.exe") {
	.\.venv\Scripts\python manage.py migrate
	.\.venv\Scripts\python manage.py test
}
else {
	python manage.py migrate
	python manage.py test
}

Write-Host "Running flutter checks..."
Set-Location "$PSScriptRoot\..\ai_medical_assistant_app"
flutter pub get
flutter test

Write-Host "Verification complete."
