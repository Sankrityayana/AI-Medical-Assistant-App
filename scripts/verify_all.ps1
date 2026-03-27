$ErrorActionPreference = "Stop"

function Invoke-Step {
	param(
		[Parameter(Mandatory = $true)]
		[string]$Command,
		[Parameter(Mandatory = $true)]
		[string]$Description
	)

	Write-Host $Description
	Invoke-Expression $Command
	if ($LASTEXITCODE -ne 0) {
		throw "Step failed ($Description) with exit code $LASTEXITCODE"
	}
}

Write-Host "Running backend checks..."
$env:USE_SQLITE = "True"
$env:DJANGO_SECRET_KEY = "verify-only-strong-secret-key-with-minimum-32-chars"
$env:POSTGRES_DB = ""
$env:POSTGRES_USER = ""
$env:POSTGRES_PASSWORD = ""
$env:POSTGRES_HOST = ""
$env:POSTGRES_PORT = ""

& "$PSScriptRoot\setup_backend.ps1"
Set-Location "$PSScriptRoot\..\backend"

$pythonExe = "python"
if (Test-Path ".venv\Scripts\python.exe") {
	$pythonExe = ".\.venv\Scripts\python"
}

Invoke-Step "$pythonExe manage.py migrate" "Applying backend migrations for verification..."
Invoke-Step "$pythonExe manage.py test" "Running backend test suite..."

Write-Host "Running flutter checks..."
Set-Location "$PSScriptRoot\..\ai_medical_assistant_app"
Invoke-Step "flutter pub get" "Installing Flutter dependencies..."
Invoke-Step "flutter test" "Running Flutter test suite..."

Write-Host "Verification complete."
