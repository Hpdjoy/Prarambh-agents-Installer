[Setup]
AppName=AIPNT Agents
AppVersion=1.0
DefaultDirName={userappdata}\AIPNT_Agents
DefaultGroupName=AIPNT
UninstallDisplayIcon={app}\aipnt-device-agent.exe
Compression=lzma2
SolidCompression=yes
OutputDir=.
OutputBaseFilename=AIPNT_Agents_Setup
PrivilegesRequired=lowest
DisableProgramGroupPage=yes

[Files]
Source: "aipnt-device-agent.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "aipnt-hardware-agent.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "run_device_agent.vbs"; DestDir: "{app}"; Flags: ignoreversion
Source: "run_hardware_agent.vbs"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\AIPNT Device Agent"; Filename: "{app}\aipnt-device-agent.exe"
Name: "{group}\Uninstall AIPNT Agents"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AIPNT_Device_Agent"; ValueData: """wscript.exe"" ""{app}\run_device_agent.vbs"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AIPNT_Hardware_Agent"; ValueData: """wscript.exe"" ""{app}\run_hardware_agent.vbs"""

[Run]
Filename: "wscript.exe"; Parameters: """{app}\run_device_agent.vbs"""; Description: "Start Device Agent"; Flags: runhidden nowait postinstall
Filename: "wscript.exe"; Parameters: """{app}\run_hardware_agent.vbs"""; Description: "Start Hardware Agent"; Flags: runhidden nowait postinstall

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    // Kill running processes before copying files
    Exec('taskkill.exe', '/F /IM aipnt-device-agent.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/F /IM aipnt-hardware-agent.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    Exec('taskkill.exe', '/F /IM aipnt-device-agent.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/F /IM aipnt-hardware-agent.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
