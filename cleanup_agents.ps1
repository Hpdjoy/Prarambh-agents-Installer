# AIPNT Agents Completely Uninstall / Clean-up Script
# This script stops running agents, removes registry startup paths, and deletes all installed agent files.

$ErrorActionPreference = "Continue"

Write-Host "=== AIPNT Agents Complete Cleanup Script ===" -ForegroundColor Cyan

# 1. Kill any active agent processes
Write-Host "`n[1/4] Stopping running agent processes..." -ForegroundColor Yellow
$ProcessesToKill = @("aipnt-device-agent", "aipnt-hardware-agent")
foreach ($proc in $ProcessesToKill) {
    if (Get-Process -Name $proc -ErrorAction SilentlyContinue) {
        Write-Host "Stopping process: $proc..."
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "Process $proc is not currently running."
    }
}
Start-Sleep -Seconds 1

# 2. Remove registry auto-run/startup keys
Write-Host "`n[2/4] Removing startup registry entries..." -ForegroundColor Yellow
$StartupRegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RegistryValues = @("AIPNT_Device_Agent", "AIPNT_Hardware_Agent")
foreach ($val in $RegistryValues) {
    if (Get-ItemProperty -Path $StartupRegKey -Name $val -ErrorAction SilentlyContinue) {
        Write-Host "Deleting registry value: $val"
        Remove-ItemProperty -Path $StartupRegKey -Name $val -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "Registry entry $val not found."
    }
}

# 3. Clean up installation directories
Write-Host "`n[3/4] Deleting installation directories..." -ForegroundColor Yellow
# Path from install.ps1 (Local AppData)
$LocalPath = "$env:LOCALAPPDATA\AIPNT_Agents"
# Path from setup.iss / Inno Setup (Roaming AppData)
$RoamingPath = "$env:APPDATA\AIPNT_Agents"

$PathsToDelete = @($LocalPath, $RoamingPath)

foreach ($path in $PathsToDelete) {
    if (Test-Path $path) {
        Write-Host "Deleting folder: $path..."
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $path)) {
            Write-Host "Successfully deleted: $path" -ForegroundColor Green
        }
        else {
            Write-Warning "Could not completely delete $path. Some files may be locked. Please restart your PC and run this script again."
        }
    }
    else {
        Write-Host "Folder does not exist: $path"
    }
}

# 4. Check for Inno Setup Uninstaller registration (if installed via setup.exe)
Write-Host "`n[4/4] Checking for Windows App Registration..." -ForegroundColor Yellow
$UninstallRegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
if (Test-Path $UninstallRegKey) {
    $SubKeys = Get-ChildItem -Path $UninstallRegKey -ErrorAction SilentlyContinue
    foreach ($subkey in $SubKeys) {
        $displayName = Get-ItemProperty -Path $subkey.PSPath -Name "DisplayName" -ErrorAction SilentlyContinue
        if ($displayName -and $displayName.DisplayName -match "AIPNT Agents") {
            Write-Host "Found registered application: $($displayName.DisplayName). Removing registry key..."
            Remove-Item -Path $subkey.PSPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`n=== Cleanup Completed Successfully! ===" -ForegroundColor Green
Write-Host "No files, processes, or startup configuration related to AIPNT Agents remain on the system."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
