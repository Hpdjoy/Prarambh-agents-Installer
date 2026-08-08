# AIPNT Agents - Complete Uninstallation & Cleanup Guide

This guide details how to completely remove the AIPNT Device Agent and AIPNT Hardware Agent from a Windows system. It ensures that no running processes, installation directories, registry keys, or startup records are left behind.

---

## Method 1: Automated Script (Recommended)

An automated script [cleanup_agents.ps1](file:///c:/Users/HpdJoy/Projects/WEB%20PROJECTS/Prarambh/AIPNT%20Agent%20Installer/cleanup_agents.ps1) has been created to perform all steps below automatically.

### How to Run it:
1. Open **PowerShell** (no administrator privileges are needed since the agents install in user-space).
2. Run the script using:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\Users\HpdJoy\Projects\WEB PROJECTS\Prarambh\AIPNT Agent Installer\cleanup_agents.ps1"
   ```

---

## Method 2: Manual Uninstallation Steps

Follow these steps if you wish to remove the files and registry entries manually.

### Step 1: Terminate Active Processes
The agents run silently in the background. Open **PowerShell** or **Command Prompt** and execute the following commands to terminate them:
```powershell
taskkill /F /IM aipnt-device-agent.exe
taskkill /F /IM aipnt-hardware-agent.exe
```
*(Alternatively, open **Task Manager** (Ctrl + Shift + Esc), find `aipnt-device-agent.exe` and `aipnt-hardware-agent.exe`, and click **End Task**).*

---

### Step 2: Remove Startup Registry Keys
To prevent the agents from launching when your computer starts, delete their registry entries under the Current User run keys.

1. Press `Win + R`, type `regedit`, and press **Enter**.
2. Navigate to:
   ```
   HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
   ```
3. Locate the following two values:
   - `AIPNT_Device_Agent`
   - `AIPNT_Hardware_Agent`
4. Right-click on each and select **Delete**.

*(Alternatively, run these commands in PowerShell)*:
```powershell
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AIPNT_Device_Agent" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AIPNT_Hardware_Agent" -ErrorAction SilentlyContinue
```

---

### Step 3: Delete Installed Files & Folders
Depending on how the agents were installed, they will be located in either your **Local AppData** or **Roaming AppData** folder:

1. Press `Win + R`, type `%localappdata%`, and press **Enter**.
   - If there is an `AIPNT_Agents` folder, delete it completely.
2. Press `Win + R`, type `%appdata%`, and press **Enter**.
   - If there is an `AIPNT_Agents` folder, delete it completely.

*(Alternatively, run these commands in PowerShell)*:
```powershell
Remove-Item -Path "$env:LOCALAPPDATA\AIPNT_Agents" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:APPDATA\AIPNT_Agents" -Recurse -Force -ErrorAction SilentlyContinue
```

---

### Step 4: Clean Up Windows App Registration (If installed via Installer)
If you ran `AIPNT_Agents_Setup.exe`, Windows registers the application for uninstallation.

1. Go to **Windows Settings** > **Apps** > **Installed Apps** (or **Add or Remove Programs**).
2. Search for **AIPNT Agents**.
3. Click **Uninstall**. 

If the uninstaller fails or the folder is already deleted, Windows will offer to remove the entry from the list.

---

### Step 5: Remove Stale Registry App Entries
If **AIPNT Agents** still appears in **Installed Apps** after the files were removed, delete the leftover uninstall registry entry.

> Warning: Editing the Windows Registry incorrectly can affect your system. Only remove entries that clearly belong to **AIPNT Agents**.

#### Option A: Remove with Registry Editor
1. Press `Win + R`, type `regedit`, and press **Enter**.
2. Check these locations:
   ```
   HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall
   HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall
   HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
   ```
3. In each location, look through the subkeys and find the one where `DisplayName` is **AIPNT Agents**.
4. Right-click that subkey and select **Export** to create a backup.
5. Right-click the same subkey again and select **Delete**.

#### Option B: Remove with PowerShell
Open **PowerShell** and run:
```powershell
$uninstallRoots = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($root in $uninstallRoots) {
    Get-ChildItem $root -ErrorAction SilentlyContinue |
        Where-Object {
            (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DisplayName -eq "AIPNT Agents"
        } |
        Remove-Item -Recurse -Force
}
```

If PowerShell reports an access denied error for `HKLM`, run PowerShell as **Administrator** and try again.
