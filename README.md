# 📊 System Monitor for Windows (PowerShell + LibreHardwareMonitor)

## 📌 Описание / Description

**[RU]** Легковесная портативная утилита мониторинга системы с терминальным интерфейсом, написанная на PowerShell. В реальном времени отображает загрузку и температуру процессора и видеокарты, оперативную память, а также заполненность диска. Все необходимые компоненты LHM и фоновый веб-сервер запускаются автоматически.

**[EN]** A lightweight, portable terminal-based system monitor written in PowerShell. Displays real-time metrics for CPU and GPU load/temperatures, RAM, and disk space. Includes an auto-launching LibreHardwareMonitor web server to pull raw sensor data without external setup.

---

## 🇷🇺 Русская версия

### 🌟 Возможности
* **Мониторинг CPU:** Процент загрузки и температура процессора (Intel Core i5-9600K и аналоги).
* **Мониторинг GPU:** Загрузка ядра (%) и температура (AMD Radeon RX 550 и аналоги).
* **ОЗУ и Диск:** Наглядный расход ресурсов с динамическими псевдографическими прогресс-барами.
* **Автоматизация:** Запуск в один клик через `start.bat` с автоматическим подъемом веб-сервера LHM на порту `8085`.
* **Портативность:** Проект работает "из коробки" без необходимости сложной ручной установки.

### 📋 Требования
* **ОС:** Windows 10 / 11
* **PowerShell:** Версия 5.1 или выше
* **Права администратора:** Обязательны для корректного доступа LHM к датчикам железа.

### 📁 Структура проекта
```text
powershell-system-monitor/
├── LHM/                        # Портативная версия LibreHardwareMonitor
│   ├── LibreHardwareMonitor.exe
│   └── LibreHardwareMonitor.config
├── sysmon.ps1                  # PowerShell-скрипт мониторинга
├── start.bat                   # Единый файл запуска (проверка админ-прав и LHM)
└── README.md                   # Документация

###🚀 Быстрый запуск
Склонируйте репозиторий или скачайте ZIP-архив:


git clone [https://github.com/crayven-adr/powershell-system-monitor.git](https://github.com/crayven-adr/powershell-system-monitor.git)
cd powershell-system-monitor
Нажмите правой кнопкой мыши по файлу start.bat и выберите «Запуск от имени администратора».

Для завершения работы монитора нажмите Ctrl + C в окне консоли.

###📜 Благодарности и Лицензия
Этот проект использует библиотеку LibreHardwareMonitor для чтения аппаратных датчиков под лицензией Mozilla Public License 2.0 (MPL 2.0).

Распространяется под лицензией MIT License.