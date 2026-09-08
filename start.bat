@echo off
chcp 65001 > nul
title System Monitor Launcher

:: Проверка прав Администратора (необходимы для доступа LHM к датчикам)
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Ошибка: Запустите start.bat от имени Администратора!
    echo.
    pause
    exit /b
)

:: Проверка: запущен ли процессы LibreHardwareMonitor
tasklist /FI "IMAGENAME eq LibreHardwareMonitor.exe" 2>NUL | find /I /N "LibreHardwareMonitor.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] LibreHardwareMonitor уже запущен.
) else (
    echo [*] Запуск LibreHardwareMonitor...
    start "" "%~dp0LHM\LibreHardwareMonitor.exe"
    :: Пауза 3 секунды, чтобы веб-сервер успел подняться
    timeout /t 3 /nobreak >nul
)

:: Запуск PowerShell-скрипта мониторинга
echo [*] Запуск системного монитора...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sysmon.ps1"

pause