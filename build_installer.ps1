$ErrorActionPreference = "Stop"

$IsccPath = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
if (-not (Test-Path $IsccPath)) {
    $IsccPath = "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
}
if (-not (Test-Path $IsccPath)) {
    $IsccPath = "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
}

if (-not (Test-Path $IsccPath)) {
    Write-Host "Inno Setup is not installed. Attempting to install via winget..."
    try {
        winget install --id JRSoftware.InnoSetup -e --accept-package-agreements --accept-source-agreements
        
        $IsccPath = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
        if (-not (Test-Path $IsccPath)) {
            $IsccPath = "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
        }
        if (-not (Test-Path $IsccPath)) {
            $IsccPath = "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
        }
    } catch {
        Write-Error "Failed to install Inno Setup. Please download and install it manually from https://jrsoftware.org/isdl.php"
        exit 1
    }
}

if (-not (Test-Path $IsccPath)) {
    Write-Error "Could not find ISCC.exe after installation. Please verify Inno Setup is installed."
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$IssFile = Join-Path $ScriptDir "setup.iss"

Write-Host "Building installer using $IsccPath..."
& $IsccPath $IssFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully built AIPNT_Agents_Setup.exe!" -ForegroundColor Green
} else {
    Write-Error "Failed to build installer."
}
