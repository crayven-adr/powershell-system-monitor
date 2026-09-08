@echo off
chcp 65001 > nul
title System Monitor Launcher

:: 1. Проверка прав Администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Ошибка: Запустите start.bat от имени Администратора!
    echo.
    pause
    exit /b
)

:: 2. Проверка наличия LHM и его автоматическое скачивание при отсутствии
if not exist "%~dp0LHM\LibreHardwareMonitor.exe" (
    echo [*] Автономный модуль LHM не найден. Начинаю скачивание с GitHub...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/crayven-adr/powershell-system-monitor/releases/download/v0.9.6-lhm/LHM.zip' -OutFile '%~dp0LHM.zip'"
    
    if not exist "%~dp0LHM.zip" (
        echo [!] Ошибка при скачивании LHM.zip. Проверьте подключение к интернету или наличие ZIP в релизе.
        echo.
        pause
        exit /b
    )

    echo [*] Распаковка компонентов LHM...
    :: Место распаковки изменено на %~dp0, так как архив уже содержит внешнюю папку LHM
    powershell -Command "Expand-Archive -Path '%~dp0LHM.zip' -DestinationPath '%~dp0' -Force"
    del "%~dp0LHM.zip"
    echo [OK] Модуль LHM успешно установлен!
    echo.
)

:: 3. Проверка и запуск LibreHardwareMonitor
tasklist /FI "IMAGENAME eq LibreHardwareMonitor.exe" 2>NUL | find /I /N "LibreHardwareMonitor.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] LibreHardwareMonitor уже запущен.
) else (
    echo [*] Запуск LibreHardwareMonitor...
    start "" "%~dp0LHM\LibreHardwareMonitor.exe"
    timeout /t 3 /nobreak >nul
)

:: 4. Запуск интерфейса PowerShell
echo [*] Запуск системного монитора...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sysmon.ps1"

pause