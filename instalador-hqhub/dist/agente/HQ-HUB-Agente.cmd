@echo off
setlocal
set "AGENTE=%~dp0assistente_local_hqhub.py"
where py >nul 2>nul
if %errorlevel% neq 0 (
  winget install --id Python.Python.3.12 --exact --silent --accept-package-agreements --accept-source-agreements
  if %errorlevel% neq 0 exit /b 1
)
py -3 -m pip install --user "playwright>=1.40,<2" "telethon>=1.36,<2" "pymupdf>=1.24,<2" >nul
py -3 -m playwright install chromium >nul
start "HQ-HUB Agente" /min py -3 "%AGENTE%" --porta 8765 --abrir-hqhub
