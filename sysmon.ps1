$ErrorActionPreference = 'SilentlyContinue'

function Get-ProgressBar ($percent, $width = 20) {
    $p = [math]::Max(0, [math]::Min(100, $percent))
    $filled = [math]::Floor($p * $width / 100)
    $empty = $width - $filled
    return "[" + ("#" * $filled) + ("-" * $empty) + "]"
}

function Get-FlatNodes($node) {
    $nodes = @($node)
    if ($node.Children) {
        foreach ($child in $node.Children) { $nodes += Get-FlatNodes $child }
    }
    return $nodes
}

try {
    $Host.UI.RawUI.CursorSize = 0
    while ($true) {
        $cpuTemp = "N/A"
        $gpuTemp = "N/A"
        $gpuLoad = 0

        try {
            $json = Invoke-RestMethod -Uri "http://localhost:8085/data.json" -TimeoutSec 1 -ErrorAction SilentlyContinue
            if ($json) {
                $allNodes = Get-FlatNodes $json

                # Отбираем узлы с численной температурой, исключая вольтаж (V), частоту (MHz), мощность (W) и проценты (%)
                $tempNodes = $allNodes | Where-Object { 
                    $_.Value -and 
                    $_.Value -notlike "*V*" -and 
                    $_.Value -notlike "*W*" -and 
                    $_.Value -notlike "*MHz*" -and 
                    $_.Value -notlike "*%*" -and
                    $_.Value -notlike "*GB*" -and
                    $_.Value -notlike "*RPM*" -and
                    ($_.Value -match "\d+")
                }

                # 1. Температура CPU (i5-9600K)
                $cTemp = $tempNodes | Where-Object { 
                    $_.Text -like "*Package*" -or $_.Text -like "*Core Max*" -or $_.Text -like "*Core #1*"
                } | Select-Object -First 1

                if (-not $cTemp) { $cTemp = $tempNodes | Select-Object -First 1 }
                if ($cTemp) { $cpuTemp = $cTemp.Value }

                # 2. Температура GPU (Radeon RX 550)
                $gTemp = $tempNodes | Where-Object { 
                    $_.Text -like "*GPU Core*" -or $_.Text -like "*GPU Hot Spot*" -or $_.Text -like "*GPU Thermal*"
                } | Select-Object -First 1

                if (-not $gTemp) { $gTemp = $tempNodes | Select-Object -Last 1 }
                if ($gTemp) { $gpuTemp = $gTemp.Value }

                # 3. Нагрузка GPU (%)
                $gLoadCandidate = $allNodes | Where-Object { 
                    $_.Text -like "*GPU Core*" -and $_.Value -like "*%*"
                } | Select-Object -First 1

                if ($gLoadCandidate) { 
                    $cleanVal = [float]($gLoadCandidate.Value -replace '[^\d\.,]','' -replace ',','.')
                    if ($cleanVal -gt 100) { $cleanVal = $cleanVal / 10 }
                    $gpuLoad = [math]::Min(100, [math]::Round($cleanVal))
                }
            }
        } catch {}

        # Метрики системы
        $cpuUsage = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average)
        
        $os = Get-CimInstance Win32_OperatingSystem
        $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1KB)
        $ramFree = [math]::Round($os.FreePhysicalMemory / 1KB)
        $ramUsed = $ramTotal - $ramFree
        $ramPercent = [math]::Round(($ramUsed / $ramTotal) * 100)

        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskTotal = [math]::Round($disk.Size / 1GB)
        $diskFree = [math]::Round($disk.FreeSpace / 1GB)
        $diskUsed = $diskTotal - $diskFree
        $diskPercent = [math]::Round(($diskUsed / $diskTotal) * 100)

        # Вывод
        Clear-Host
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "             SYSTEM MONITOR (PowerShell)          " -ForegroundColor Cyan
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to exit`n"

        Write-Host ("CPU Load:   {0,3}% " -f $cpuUsage) -NoNewline
        Write-Host (Get-ProgressBar $cpuUsage) -ForegroundColor Yellow
        Write-Host "CPU Temp:   $cpuTemp (i5-9600K)" -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

        Write-Host ("GPU Load:   {0,3}% " -f $gpuLoad) -NoNewline
        Write-Host (Get-ProgressBar $gpuLoad) -ForegroundColor Yellow
        Write-Host "GPU Temp:   $gpuTemp (Radeon RX 550)" -ForegroundColor Cyan
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
    $Host.UI.RawUI.CursorSize = 25
}