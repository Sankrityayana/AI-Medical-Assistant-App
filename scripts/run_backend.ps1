$ErrorActionPreference = "Stop"

Set-Location "$PSScriptRoot\..\backend"

if (Test-Path ".venv\Scripts\python.exe") {
	.\.venv\Scripts\python manage.py runserver
}
else {
	python manage.py runserver
}
