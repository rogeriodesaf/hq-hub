@echo off
setlocal
set "AGENTE=%~dp0assistente_local_hqhub.py"
set "LOG=%~dp0agente.log"
echo [%date% %time%] Iniciando agente > "%LOG%"
where py >nul 2>nul
if %errorlevel% equ 0 (
  set "PYTHON=py -3"
) else (
  where python >nul 2>nul
  if %errorlevel% equ 0 (set "PYTHON=python") else (
    echo Python nao encontrado. >> "%LOG%"
  winget install --id Python.Python.3.12 --exact --silent --accept-package-agreements --accept-source-agreements
    if %errorlevel% neq 0 exit /b 1
    set "PYTHON=py -3"
  )
)
%PYTHON% -m pip install --user "playwright>=1.40,<2" "telethon>=1.36,<2" "pymupdf>=1.24,<2" >> "%LOG%" 2>&1
if %errorlevel% neq 0 exit /b 1
%PYTHON% -m playwright install chromium >> "%LOG%" 2>&1
if %errorlevel% neq 0 exit /b 1
echo [%date% %time%] Agente conectado na porta 8765 >> "%LOG%"
%PYTHON% "%AGENTE%" --porta 8765 --abrir-hqhub >> "%LOG%" 2>&1
