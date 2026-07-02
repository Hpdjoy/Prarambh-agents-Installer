Set WshShell = CreateObject("WScript.Shell")
appDataPath = WshShell.ExpandEnvironmentStrings("%APPDATA%")
WshShell.CurrentDirectory = appDataPath & "\AIPNT_Agents"
WshShell.Run """" & appDataPath & "\AIPNT_Agents\aipnt-hardware-agent.exe""", 0, False
