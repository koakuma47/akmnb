#Requires -Version 5.1
<#
  build.ps1 - one click build for AKM Launcher.

  Usage:
      powershell -ExecutionPolicy Bypass -File build.ps1
      powershell -ExecutionPolicy Bypass -File build.ps1 -Version 1.3
      powershell -ExecutionPolicy Bypass -File build.ps1 -Sign -PfxPath cert.pfx -PfxPassword ****

  Output:
      AKM_Launcher.exe                      (next to win1_gui.py)
      release\AKM_Launcher_v<ver>\          (EXE + README + notes)
      release\AKM_Launcher_v<ver>.zip
      release\SHA256.txt
#>
param(
    [string]$Version = "",
    [switch]$Sign,
    [string]$PfxPath = "",
    [string]$PfxPassword = "",
    [string]$TimestampUrl = "http://timestamp.digicert.com"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

function Write-Step($text) { Write-Host "[BUILD] $text" -ForegroundColor Cyan }

# 1) resolve version from the source if not given
if (-not $Version) {
    $match = Select-String -Path "win1_gui.py" -Pattern 'APP_VERSION\s*=\s*"([^"]+)"' |
        Select-Object -First 1
    if ($match -and $match.Matches.Count -gt 0) {
        $Version = $match.Matches[0].Groups[1].Value
    } else {
        $Version = "0.0"
    }
}
Write-Step "version = $Version"
$tag = $Version
if ($Version -notmatch '^[A-Za-z]') { $tag = "v$Version" }
Write-Step "tag = $tag"

# 2) dependencies
Write-Step "checking dependencies"
python -c "import PyInstaller, minecraft_launcher_lib" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Step "installing pyinstaller / minecraft-launcher-lib"
    python -m pip install --upgrade pyinstaller minecraft-launcher-lib
}

# 3) regenerate the encrypted donate payload (only when donate.png exists)
if (Test-Path "donate.png") {
    Write-Step "regenerating qr payload"
    python make_qr_payload.py
} else {
    Write-Step "donate.png missing - keeping existing qr_payload.py"
}

# 4) pyinstaller
Write-Step "running pyinstaller"
python -m PyInstaller --noconfirm --clean --onefile --windowed `
    --name AKM_Launcher `
    --icon "$root\akm_icon.ico" `
    --add-data "$root\akm_icon.ico;." `
    --add-data "$root\lang;lang" `
    --distpath "$root" `
    --workpath "$root\_build" `
    --specpath "$root\_build" `
    --collect-all minecraft-launcher-lib `
    win1_gui.py
if ($LASTEXITCODE -ne 0) { throw "pyinstaller failed" }

# 5) optional code signing
if ($Sign) {
    if (-not $PfxPath) { throw "-Sign requires -PfxPath" }
    Write-Step "signing AKM_Launcher.exe"
    & "$root\sign.ps1" -FilePath "$root\AKM_Launcher.exe" `
        -PfxPath $PfxPath -PfxPassword $PfxPassword -TimestampUrl $TimestampUrl
    if ($LASTEXITCODE -ne 0) { throw "signing failed" }
}

# 6) self test of the frozen exe
Write-Step "running frozen selftest"
$logPath = Join-Path $root "logs\selftest.log"
Remove-Item $logPath -Force -ErrorAction SilentlyContinue
$proc = Start-Process -FilePath "$root\AKM_Launcher.exe" -ArgumentList "--selftest" `
    -WorkingDirectory $root -Wait -PassThru -WindowStyle Hidden
if ($proc.ExitCode -ne 0) { throw "selftest exit code $($proc.ExitCode)" }
if (-not (Test-Path $logPath)) { throw "selftest log missing" }
Get-Content $logPath | Select-String -Pattern "selftest complete" | Out-Null
Write-Step "selftest OK"

# 7) release folder + zip + hashes
$releaseRoot = Join-Path $root "release"
$folder = Join-Path $releaseRoot "AKM_Launcher_$tag"
Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $folder | Out-Null
Copy-Item "$root\AKM_Launcher.exe" $folder -Force
Copy-Item "$root\README_AKM.md" $folder -Force -ErrorAction SilentlyContinue
Copy-Item "$root\RELEASE_NOTES.txt" $folder -Force -ErrorAction SilentlyContinue

# publish the exe hash inside the package so users can verify it
$exeHashForFile = (Get-FileHash (Join-Path $folder "AKM_Launcher.exe") -Algorithm SHA256).Hash
[System.IO.File]::WriteAllText((Join-Path $folder "AKM_Launcher.exe.sha256"),
    "$exeHashForFile  AKM_Launcher.exe`r`n", (New-Object System.Text.UTF8Encoding($false)))

$zip = Join-Path $releaseRoot "AKM_Launcher_$tag.zip"
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $folder "*") -DestinationPath $zip -CompressionLevel Optimal

$exeHash = (Get-FileHash (Join-Path $folder "AKM_Launcher.exe") -Algorithm SHA256).Hash
$zipHash = (Get-FileHash $zip -Algorithm SHA256).Hash
$shaText = "AKM Launcher $tag - SHA256`r`n" +
    "========================================`r`n" +
    "AKM_Launcher.exe       : $exeHash`r`n" +
    "AKM_Launcher_$tag.zip  : $zipHash`r`n"
[System.IO.File]::WriteAllText((Join-Path $releaseRoot "SHA256.txt"), $shaText,
    (New-Object System.Text.UTF8Encoding($true)))

Write-Step "done"
Write-Host ""
Write-Host "  release folder : $folder"
Write-Host "  release zip    : $zip"
Write-Host "  exe  sha256    : $exeHash"
Write-Host "  zip  sha256    : $zipHash"
Write-Host ""
