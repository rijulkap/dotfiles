$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Version = "v0.1.8"
$Repository = "rijulkap/dotstrap"

if ($PSVersionTable.PSEdition -eq "Core" -and -not $IsWindows) {
    throw "This downloader is intended for Windows. Use download.sh on Linux or macOS."
}

$Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
if ($Architecture -ne [System.Runtime.InteropServices.Architecture]::X64) {
    throw "Unsupported Windows architecture: $Architecture. The release provides Windows x64 only."
}

$Asset = "dotstrap-windows-x64.exe"
$Url = "https://github.com/$Repository/releases/download/$Version/$Asset"
$Destination = Join-Path $PSScriptRoot "dotstrap.exe"
$Temporary = Join-Path $PSScriptRoot ".dotstrap.download.$PID"

try {
    Write-Host "Downloading $Url"
    Invoke-WebRequest -Uri $Url -OutFile $Temporary
    Move-Item -LiteralPath $Temporary -Destination $Destination -Force
    Write-Host "Installed dotstrap at $Destination"
}
finally {
    if (Test-Path -LiteralPath $Temporary) {
        Remove-Item -LiteralPath $Temporary -Force
    }
}
