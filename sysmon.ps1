# Подавляем лишние системные предупреждения при загрузке типов
$ErrorActionPreference = 'SilentlyContinue'

# Автоматический поиск DLL в папке со скриптом
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dllFile = Get-ChildItem -Path $scriptDir -Filter "*LibreHardwareMonitor*.dll" | Select-Object -First 1

if (-not $dllFile) {
    Write-Host "DLL file not found in $scriptDir!" -ForegroundColor Red
    exit
}

# Загружаем библиотеку
Add-Type -Path $dllFile.FullName

# Настраиваем только CPU, чтобы не запрашивать лишние датчики
$computer = New-Object LibreHardwareMonitor.Hardware.Computer
$computer.IsCpuEnabled = $true
$computer.Open()

function Get-ProgressBar ($percent, $width = 25) {
    $filled = [math]::Floor($percent * $width / 100)
    $empty = $width - $filled
    return "[" + ("#" * $filled) + ("-" * $empty) + "]"
}

function Get-GpuInfo {
    $nvidiaSmi = Get-Command "nvidia-smi.exe" -ErrorAction SilentlyContinue
    if ($nvidiaSmi) {
        $gpuData = & nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>$null
        if ($gpuData) {
            $parts = $gpuData.Split(",")
            return "NVIDIA GPU:  " + $parts[0].Trim() + " C | Load: " + $parts[1].Trim() + "%"
        }
    }
    return "GPU:         N/A"
}

try {
    $Host.UI.RawUI.CursorSize = 0
    while ($true) {
        # CPU
        $cpuUsage = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average)
        $cpuTemp = "N/A"
        
        foreach ($hardware in $computer.Hardware) {
            $hardware.Update()
            if ($hardware.HardwareType -eq [LibreHardwareMonitor.Hardware.HardwareType]::Cpu) {
                $packageTemp = $hardware.Sensors | Where-Object { $_.SensorType -eq [LibreHardwareMonitor.Hardware.SensorType]::Temperature -and ($_.Name -like "*Package*" -or $_.Name -like "*Core Average*") } | Select-Object -First 1
                if ($packageTemp -and $packageTemp.Value) {
                    $cpuTemp = "$([math]::Round($packageTemp.Value)) C"
                }
            }
        }

        # RAM
        $os = Get-CimInstance Win32_OperatingSystem
        $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1KB)
        $ramFree = [math]::Round($os.FreePhysicalMemory / 1KB)
        $ramUsed = $ramTotal - $ramFree
        $ramPercent = [math]::Round(($ramUsed / $ramTotal) * 100)

        # Disk C:
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskTotal = [math]::Round($disk.Size / 1GB)
        $diskFree = [math]::Round($disk.FreeSpace / 1GB)
        $diskUsed = $diskTotal - $diskFree
        $diskPercent = [math]::Round(($diskUsed / $diskTotal) * 100)

        # Output
        Clear-Host
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "             SYSTEM MONITOR (PowerShell)          " -ForegroundColor Cyan
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to exit`n"

        Write-Host ("CPU Load:   {0,3}% " -f $cpuUsage) -NoNewline
        Write-Host (Get-ProgressBar $cpuUsage) -ForegroundColor Yellow
        Write-Host "CPU Temp:   $cpuTemp" -ForegroundColor Green
        Write-Host (Get-GpuInfo)
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

        Write-Host ("RAM Load:   {0,3}% ({1}MB / {2}MB)" -f $ramPercent, $ramUsed, $ramTotal)
        Write-Host "            " -NoNewline
        Write-Host (Get-ProgressBar $ramPercent) -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

        Write-Host ("Disk (C:):  {0,3}% ({1}GB / {2}GB)" -f $diskPercent, $diskUsed, $diskTotal)
        Write-Host "            " -NoNewline
        Write-Host (Get-ProgressBar $diskPercent) -ForegroundColor Magenta
        Write-Host "==================================================" -ForegroundColor Cyan

        Start-Sleep -Seconds 2
    }
} finally {
    if ($computer) { $computer.Close() }
    $Host.UI.RawUI.CursorSize = 25
}