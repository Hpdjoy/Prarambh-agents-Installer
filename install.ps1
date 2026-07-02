$ErrorActionPreference = "Stop"

# Define Paths
$InstallDir = "$env:LOCALAPPDATA\AIPNT_Agents"
$StartupRegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$DeviceAgentName = "aipnt-device-agent"
$HardwareAgentName = "aipnt-hardware-agent"

# Source files (assuming they are in the same directory as this script)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DeviceExe = Join-Path $ScriptDir "$DeviceAgentName.exe"
$HardwareExe = Join-Path $ScriptDir "$HardwareAgentName.exe"

Write-Host "Installing AIPNT Agents..."

if (-not (Test-Path $DeviceExe) -or -not (Test-Path $HardwareExe)) {
    Write-Error "Could not find the agent executables. Make sure $DeviceAgentName.exe and $HardwareAgentName.exe are in the same folder as this script!"
    exit 1
}

# Kill any existing instances if updating
Write-Host "Stopping any running agents..."
Stop-Process -Name $DeviceAgentName -ErrorAction SilentlyContinue
Stop-Process -Name $HardwareAgentName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Create installation directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

# Copy executables
Write-Host "Copying files to $InstallDir..."
Copy-Item -Path $DeviceExe -Destination $InstallDir -Force
Copy-Item -Path $HardwareExe -Destination $InstallDir -Force

# Create VBScript wrappers to run silently in the background without terminal windows
$DeviceVbs = Join-Path $InstallDir "run_device_agent.vbs"
$HardwareVbs = Join-Path $InstallDir "run_hardware_agent.vbs"

Set-Content -Path $DeviceVbs -Value "CreateObject(`"WScript.Shell`").Run `"`"`"$InstallDir\$DeviceAgentName.exe`"`"`", 0, False"
Set-Content -Path $HardwareVbs -Value "CreateObject(`"WScript.Shell`").Run `"`"`"$InstallDir\$HardwareAgentName.exe`"`"`", 0, False"

# Add to Windows Startup via Registry
Write-Host "Adding agents to Windows Startup..."
Set-ItemProperty -Path $StartupRegKey -Name "AIPNT_Device_Agent" -Value "`"wscript.exe`" `"$DeviceVbs`""
Set-ItemProperty -Path $StartupRegKey -Name "AIPNT_Hardware_Agent" -Value "`"wscript.exe`" `"$HardwareVbs`""

# Start the agents now
Start-Process -FilePath "wscript.exe" -ArgumentList "`"$DeviceVbs`""
Start-Process -FilePath "wscript.exe" -ArgumentList "`"$HardwareVbs`""

Write-Host ""
Write-Host "Installation Complete! The AIPNT Device and Hardware agents are now running silently in the background."
Write-Host "They will automatically start every time you turn on your computer."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
