@echo off
REM Cek apakah dijalankan dengan hak administrator
openfiles >nul 2>&1 || (
    echo Membuka ulang dengan hak administrator...
    powershell start -verb runas cmd "/c %~dp0runme.bat"
    exit /b
)

REM Jalankan skrip PowerShell
powershell -ExecutionPolicy Bypass -File "%~dp0script.ps1"
pause
