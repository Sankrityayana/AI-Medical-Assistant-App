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
  Invoke-Step ".\.venv\Scripts\python -m pip install --upgrade pip" "Upgrading pip in backend virtual environment..."
  Invoke-Step ".\.venv\Scripts\python -m pip install -r requirements.txt" "Installing backend dependencies in virtual environment..."
  $pythonExe = ".\.venv\Scripts\python"
}
else {
  Invoke-Step "python -m pip install --upgrade pip" "Upgrading system pip..."
  Invoke-Step "python -m pip install -r requirements.txt" "Installing backend dependencies with system Python..."
  $pythonExe = "python"
}

if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "Created backend .env from .env.example"
}

Invoke-Step "$pythonExe manage.py migrate" "Applying backend migrations..."
Write-Host "Backend setup complete."
