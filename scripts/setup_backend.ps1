$ErrorActionPreference = "Stop"

Set-Location "$PSScriptRoot\..\backend"

if (-not (Test-Path ".venv\Scripts\python.exe")) {
  try {
    python -m venv .venv
  }
  catch {
    Write-Host "Virtual environment setup failed. Falling back to system Python." -ForegroundColor Yellow
  }
}

if (Test-Path ".venv\Scripts\python.exe") {
  .\.venv\Scripts\python -m pip install --upgrade pip
  .\.venv\Scripts\python -m pip install -r requirements.txt
  $pythonExe = ".\.venv\Scripts\python"
}
else {
  python -m pip install --upgrade pip
  python -m pip install -r requirements.txt
  $pythonExe = "python"
}

if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "Created backend .env from .env.example"
}

& $pythonExe manage.py migrate
Write-Host "Backend setup complete."
