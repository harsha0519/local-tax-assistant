# Installs Ollama, applies speed settings, and downloads the models.
# Run in PowerShell:  .\scripts\setup-ollama.ps1

$ErrorActionPreference = "Stop"

# 1. Install Ollama (skip if already installed)
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Ollama..."
    winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
    Write-Host "Ollama installed. Close and reopen PowerShell, then run this script again."
    exit
}

# 2. Speed / memory settings (saved for your Windows user)
#    - 32K context so RAG passages fit
#    - Flash attention + q8_0 KV cache: ~7 -> ~57 tokens/sec on an RTX 4070
[Environment]::SetEnvironmentVariable("OLLAMA_CONTEXT_LENGTH", "32768", "User")
[Environment]::SetEnvironmentVariable("OLLAMA_FLASH_ATTENTION", "1", "User")
[Environment]::SetEnvironmentVariable("OLLAMA_KV_CACHE_TYPE", "q8_0", "User")
Write-Host "Settings saved. Restart the Ollama app (tray icon > Quit, then reopen) to apply them."

# 3. Download models
ollama pull hf.co/empero-ai/Qwen3.8-35B-A3B-Distill-GGUF:Q4_K_M   # chat model (~21 GB)
ollama pull qwen3-embedding:0.6b                                   # embeddings for RAG (~0.6 GB)

Write-Host "`nDone. Installed models:"
ollama list
