@echo off
chcp 65001 > nul
title System Monitor Launcher

cd /d "%~dp0"

:: 1. Проверка прав Администратора
net session >nul 2>&1
if %errorLevel% neq 0 goto NO_ADMIN

:: 2. Проверка наличия LHM
if exist "%~dp0LHM\LibreHardwareMonitor.exe" goto RUN_LHM

echo [*] Автономный модуль LHM не найден. Скачивание с GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/crayven-adr/powershell-system-monitor/releases/download/v0.9.6-lhm/LHM.zip' -OutFile '%~dp0LHM.zip'"

if not exist "%~dp0LHM.zip" goto DOWNLOAD_ERROR

echo [*] Распаковка компонентов LHM...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%~dp0LHM.zip' -DestinationPath '%~dp0' -Force"
del /f /q "%~dp0LHM.zip"
echo [OK] Модуль LHM успешно установлен!
echo.

:RUN_LHM
:: 3. Проверка и запуск LibreHardwareMonitor.exe
tasklist /FI "IMAGENAME eq LibreHardwareMonitor.exe" 2>NUL | find /I /N "LibreHardwareMonitor.exe">NUL
if %ERRORLEVEL%==0 (
    echo [OK] LibreHardwareMonitor уже запущен.
    goto RUN_PS
)

echo [*] Запуск LibreHardwareMonitor.exe...
start "" "%~dp0LHM\LibreHardwareMonitor.exe"
echo [*] Ожидание инициализации датчиков (6 сек)...
timeout /t 6 /nobreak >nul

:RUN_PS
:: 4. Запуск основного скрипта PowerShell
echo [*] Запуск системного монитора...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sysmon.ps1"
echo.
echo [*] Работа скрипта завершена.
pause
exit /b 0

:NO_ADMIN
echo [!] Ошибка: Нет прав Администратора!
echo Пожалуйста, нажмите правой кнопкой мыши по start.bat и выберите "Запуск от имени администратора".
echo.
pause
exit /b 1

:DOWNLOAD_ERROR
echo [!] Ошибка при скачивании LHM.zip. Проверьте подключение к интернету или ссылку.
echo.
pause
exit /b 1