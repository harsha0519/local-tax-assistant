# Installs Open WebUI (first run only) and starts it at http://localhost:8080
# Run in PowerShell:  .\scripts\start-openwebui.ps1
# Keep this window open while you use it. Press Ctrl+C to stop.

$ErrorActionPreference = "Stop"

# Where Open WebUI keeps chats, settings and the knowledge base
$dataDir = Join-Path $env:USERPROFILE ".open-webui"

# Install uv (Python package manager) if missing
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    winget install --id astral-sh.uv -e --accept-source-agreements --accept-package-agreements
    Write-Host "uv installed. Close and reopen PowerShell, then run this script again."
    exit
}

# Install Open WebUI if missing
if (-not (Get-Command open-webui -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Open WebUI (a few minutes)..."
    uv tool install --python 3.11 open-webui
}

# Check Ollama is running
try {
    Invoke-WebRequest http://localhost:11434/api/version -UseBasicParsing -TimeoutSec 3 | Out-Null
} catch {
    Write-Warning "Ollama doesn't seem to be running. Open the Ollama app from the Start menu."
}

$env:DATA_DIR = $dataDir
Write-Host "Starting Open WebUI. Open http://localhost:8080 when you see 'Uvicorn running'."
open-webui serve --port 8080
