#Requires -Version 5.1
<#
  sign.ps1 - sign AKM_Launcher.exe with an Authenticode certificate.

  A trusted certificate (OV / EV code signing) must be purchased separately;
  this script only automates the signing step. For local testing you can create
  a self signed certificate:

      powershell -File sign.ps1 -CreateSelfSigned -OutPfx test.pfx -OutPassword 123456

  Then sign:

      powershell -File sign.ps1 -FilePath AKM_Launcher.exe -PfxPath test.pfx -PfxPassword 123456

  Note: a self signed certificate only silences warnings on machines that trust
  it; public distribution requires a certificate from a public CA (DigiCert,
  Sectigo, SSL.com, ...).
#>
param(
    [string]$FilePath = "AKM_Launcher.exe",
    [string]$PfxPath = "",
    [string]$PfxPassword = "",
    [string]$TimestampUrl = "http://timestamp.digicert.com",
    [switch]$CreateSelfSigned,
    [string]$OutPfx = "akm_selfsigned.pfx",
    [string]$OutPassword = "akm-test",
    [string]$Subject = "CN=AKM Launcher (self signed)"
)

$ErrorActionPreference = "Stop"

function Find-SignTool {
    $candidates = @()
    $sdkRoot = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\bin"
    if (Test-Path $sdkRoot) {
        $candidates += Get-ChildItem $sdkRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName "x64\signtool.exe" }
    }
    $candidates += (Get-Command signtool.exe -ErrorAction SilentlyContinue).Source
    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }
    throw "signtool.exe not found. Install the Windows 10/11 SDK (Signing Tools)."
}

if ($CreateSelfSigned) {
    $cert = New-SelfSignedCertificate -Type CodeSigningCert `
        -Subject $Subject `
        -KeyUsage DigitalSignature `
        -FriendlyName "AKM Launcher test signing" `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -NotAfter (Get-Date).AddYears(3)
    $secure = ConvertTo-SecureString -String $OutPassword -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $OutPfx -Password $secure | Out-Null
    Write-Host "[SIGN] self signed certificate exported: $OutPfx" -ForegroundColor Yellow
    Write-Host "[SIGN] thumbprint: $($cert.Thumbprint)"
    exit 0
}

if (-not (Test-Path $FilePath)) { throw "file not found: $FilePath" }
if (-not $PfxPath -or -not (Test-Path $PfxPath)) { throw "pfx not found: $PfxPath" }

$signTool = Find-SignTool
$signArgs = @(
    "sign", "/fd", "SHA256", "/td", "SHA256", "/tr", $TimestampUrl,
    "/f", $PfxPath
)
if ($PfxPassword) { $signArgs += @("/p", $PfxPassword) }
$signArgs += $FilePath

Write-Host "[SIGN] $signTool $($signArgs -join ' ')"
& $signTool @signArgs
if ($LASTEXITCODE -ne 0) { throw "signtool failed with exit code $LASTEXITCODE" }

Write-Host "[SIGN] verifying signature" -ForegroundColor Cyan
& $signTool verify /pa /v $FilePath | Select-Object -Last 6
Write-Host "[SIGN] done"
