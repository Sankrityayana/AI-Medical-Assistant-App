$ErrorActionPreference = "Stop"

Set-Location "$PSScriptRoot\..\ai_medical_assistant_app"
flutter pub get
flutter run
