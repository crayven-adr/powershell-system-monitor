# 📊 System Monitor for Windows (PowerShell)

## 📌 Описание / Description

**[RU]** Легковесная утилита мониторинга системы с терминальным интерфейсом, написанная на PowerShell. В реальном времени отображает загрузку процессора, оперативную память, заполненность диска, а также температуры ЦПУ и видеокарты.

**[EN]** A lightweight, terminal-based hardware monitoring tool written in PowerShell. It displays real-time system metrics including CPU load, CPU temperature, RAM usage, disk usage, and GPU stats.

---

## 🇷🇺 Русская версия

### 🌟 Возможности
* **Мониторинг CPU:** Процент загрузки и точная температура пакета ядер.
* **Мониторинг GPU:** Температура и уровень загрузки (для карт NVIDIA через `nvidia-smi`).
* **ОЗУ и Диск:** Объемы памяти и динамические псевдографические индикаторы (прогресс-бары).
* **Автообновление:** Периодический сброс и обновление данных каждые 2 секунды.

### 📋 Требования
* **ОС:** Windows 10 / 11
* **PowerShell:** Версия 5.1 или выше
* **Права администратора:** Обязательны для чтения низкоуровневых датчиков температуры.
* **Библиотека:** `LibreHardwareMonitorLib.dll` (находится в репозитории).

### 🚀 Быстрый запуск

1. Склонируйте репозиторий или скачайте архив:
   ```cmd
   git clone [https://github.com/crayven-adr/powershell-system-monitor.git](https://github.com/crayven-adr/powershell-system-monitor.git)
   cd powershell-system-monitor

## Credits
This project uses the [LibreHardwareMonitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) library for reading CPU hardware sensors under the Mozilla Public License 2.0 (MPL 2.0).