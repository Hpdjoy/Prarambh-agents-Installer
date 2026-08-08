# Installation Guide: Prarambh Agents Installer

This installer sets up and runs the two background agents required for the **Prarambh AIPNT Coding Platform**:

- `aipnt-device-agent.exe` (Port 20559 - Hardware authentication & cryptographic identity)
- `aipnt-hardware-agent.exe` (Port 20557 - Arduino & robot USB compiling and flashing)

It copies them into your local app data folder and configures them to start automatically when Windows boots. The installer also runs both agents silently in the background using VBScript wrappers without leaving open terminal windows on student screens.

---

## 📦 What is Included

The installer package contains the following files:

| File | Description |
|---|---|
| `README.md` | Installation and usage instructions |
| `install.ps1` | Automated PowerShell installer and startup configurator |
| `cleanup_agents.ps1` | Complete uninstaller and registry cleanup script |
| `UNINSTALL_GUIDE.md` | Detailed manual and automated uninstallation steps |
| `build_installer.ps1` | Script to build the single-file setup package |
| `AIPNT_Agents_Setup.exe` | Inno Setup compiled installer GUI |
| `aipnt-device-agent.exe` | Compiled Device Agent executable |
| `aipnt-hardware-agent.exe` | Compiled Hardware Agent executable |
| `run_device_agent.vbs` | Silent VBScript background runner for Device Agent |
| `run_hardware_agent.vbs` | Silent VBScript background runner for Hardware Agent |
| `setup.iss` | Inno Setup configuration script |

---

## 💻 Requirements

- **Operating System:** Windows 10 or Windows 11 (64-bit)
- **PowerShell:** PowerShell 5.1+ (Built into Windows)
- The two agent executables placed in the same folder as `install.ps1`:
  - `aipnt-device-agent.exe`
  - `aipnt-hardware-agent.exe`
- **Optional for Arduino Uploading:** `arduino-cli` installed and on PATH with `arduino:avr` core (`arduino-cli core install arduino:avr`).

---

## 🚀 How to Install

### Option A: PowerShell Script (Quickest & Silent)

1. Open the folder containing `install.ps1`.
2. Make sure `aipnt-device-agent.exe` and `aipnt-hardware-agent.exe` are in the same folder.
3. Open **PowerShell** in that folder and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

### Option B: Windows GUI Installer

1. Double-click `AIPNT_Agents_Setup.exe`.
2. Follow the wizard prompts to install the background services.

---

## ⚙️ What the Installer Does

When you run `install.ps1`, it automatically:

1. **Pre-flight Checks:** Verifies that both `aipnt-device-agent.exe` and `aipnt-hardware-agent.exe` exist.
2. **Process Management:** Stops any already running copies of the agents if updating.
3. **File Deployment:** Creates the target directory `%LOCALAPPDATA%\AIPNT_Agents` and copies the executables into place.
4. **Silent Runners:** Generates `run_device_agent.vbs` and `run_hardware_agent.vbs` wrappers to suppress console windows.
5. **Auto-Start Registration:** Adds both agents to the Windows Registry startup key (`HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`).
6. **Immediate Startup:** Launches both agents in the background immediately so students can begin coding without rebooting.

---

## 🔄 After Installation

Once installed, the agents will:
- Run silently in the background (no open Command Prompt or PowerShell windows).
- Automatically launch on every Windows boot.
- Listen on `http://localhost:20559` (Device Agent) and `http://localhost:20557` (Hardware Agent).

---

## 🗑️ How to Uninstall / Cleanup

### Automated Removal (Recommended)
Open PowerShell in the installer folder and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\cleanup_agents.ps1
```

### Manual Removal
1. **Stop active processes:**
   ```powershell
   taskkill /F /IM aipnt-device-agent.exe
   taskkill /F /IM aipnt-hardware-agent.exe
   ```
2. **Remove Startup Registry entries:**
   ```powershell
   Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AIPNT_Device_Agent" -ErrorAction SilentlyContinue
   Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AIPNT_Hardware_Agent" -ErrorAction SilentlyContinue
   ```
3. **Delete installed directories:**
   ```powershell
   Remove-Item -Path "$env:LOCALAPPDATA\AIPNT_Agents" -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item -Path "$env:APPDATA\AIPNT_Agents" -Recurse -Force -ErrorAction SilentlyContinue
   ```
