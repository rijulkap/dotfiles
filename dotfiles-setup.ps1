[CmdletBinding()]
param(
    [Parameter(Position = 0)] [string[]]$Name,
    [ValidateSet('InstallOnly','InstallAndConfigure','ConfigureOnly')] [string]$Mode = 'InstallOnly',
    [switch]$All,
    [switch]$List,
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ManifestPath = if ($env:DOTFILES_MANIFEST) { $env:DOTFILES_MANIFEST } else { Join-Path $PSScriptRoot 'dotfiles-manifest.yaml' }
$YqVersion = 'v4.44.3'
$SelectedTools = @{}
$SelectedConfigs = @{}
$ToolStack = @{}
$ToolDone = @{}

function Ensure-Yq {
    $existing = Get-Command yq -ErrorAction SilentlyContinue
    if ($existing -and ((& yq --version) -match 'mikefarah')) { return }
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host 'Installing yq using Chocolatey...'
        if (-not $DryRun) {
            choco install yq -y
            Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue
            Update-SessionEnvironment -ErrorAction SilentlyContinue
        }
        return
    }
    $dir = Join-Path $env:LOCALAPPDATA 'Programs\yq'
    $exe = Join-Path $dir 'yq.exe'
    Write-Host "Installing yq $YqVersion..."
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Invoke-WebRequest -Uri "https://github.com/mikefarah/yq/releases/download/$YqVersion/yq_windows_amd64.exe" -OutFile $exe
        $env:PATH = "$dir;$env:PATH"
    }
}

function Read-Yaml([string]$Expression) {
    $json = & yq -o=json $Expression $ManifestPath
    if ($LASTEXITCODE -ne 0) { throw "Failed to read $ManifestPath" }
    if (-not $json) { return $null }
    return $json | ConvertFrom-Json
}
function Prop($Object, [string]$Name) {
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($p) { return $p.Value }
    return $null
}
function PlatformValue($Value) {
    if ($null -eq $Value) { return $null }
    if ($Value -is [string] -or $Value -is [array]) { return $Value }
    return Prop $Value 'windows'
}
function Select-Tool([string]$ToolName) {
    $tool = Prop $script:Tools $ToolName
    if (-not $tool) { throw "Unknown tool: $ToolName" }
    $SelectedTools[$ToolName] = $true
    foreach ($cfg in @(Prop $tool 'configs')) { if ($cfg) { $SelectedConfigs[[string]$cfg] = $true } }
}
function Select-Tag([string]$TagName) {
    if (-not (Prop $script:Tags $TagName)) { throw "Unknown tag: $TagName" }
    foreach ($toolName in $script:Tools.PSObject.Properties.Name) {
        $tool = Prop $script:Tools $toolName
        $tags = @(Prop $tool 'tags')
        if ($tags -contains $TagName) { Select-Tool $toolName }
    }
}
function Tool-Installed($Definition) {
    $check = PlatformValue (Prop $Definition 'check')
    if (-not $check -or $check -eq 'null') { return $false }
    return [bool](Get-Command ([string]$check) -ErrorAction SilentlyContinue)
}
function Run-Command([string]$Command) {
    Write-Host "> $Command"
    if (-not $DryRun) { Invoke-Expression $Command }
}
function Install-Tool([string]$ToolName) {
    if ($ToolDone.ContainsKey($ToolName)) { return }
    if ($ToolStack.ContainsKey($ToolName)) { throw "Dependency cycle detected at '$ToolName'" }
    $definition = Prop $script:Tools $ToolName
    if (-not $definition) { throw "Unknown tool: $ToolName" }
    $ToolStack[$ToolName] = $true
    foreach ($dep in @(PlatformValue (Prop $definition 'depends_on'))) { if ($dep) { Install-Tool ([string]$dep) } }
    $ToolStack.Remove($ToolName)
    if (-not $Force -and (Tool-Installed $definition)) { Write-Host "Already installed: $ToolName" }
    else {
        Write-Host "Installing: $ToolName"
        $commands = @(Prop (Prop $definition 'install') 'windows')
        if ($commands.Count -eq 0) { Write-Warning "No Windows install commands for '$ToolName'" }
        foreach ($cmd in $commands) { Run-Command ([string]$cmd) }
    }
    $ToolDone[$ToolName] = $true
}
function Resolve-Target([string]$Target) {
    if ($Target.StartsWith('~/') -or $Target.StartsWith('~\')) {
        return Join-Path $HOME ($Target.Substring(2).Replace('/', [IO.Path]::DirectorySeparatorChar))
    }
    return [Environment]::ExpandEnvironmentVariables($Target)
}
function Configure-Item([string]$ConfigName) {
    $definition = Prop $script:Configs $ConfigName
    if (-not $definition) { throw "Unknown config: $ConfigName" }
    $targetRaw = Prop (Prop $definition 'targets') 'windows'
    if (-not $targetRaw) { Write-Host "No Windows target for config: $ConfigName"; return }
    $source = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ([string](Prop $definition 'source'))))
    $target = Resolve-Target ([string]$targetRaw)
    if (-not (Test-Path -LiteralPath $source)) { Write-Warning "Missing config source: $source"; return }
    $existing = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($existing) {
        $correct = $false
        if ($existing.LinkType -eq 'SymbolicLink') {
            try { $correct = ([IO.Path]::GetFullPath(@($existing.Target)[0]) -eq $source) } catch { }
        }
        if ($correct) { Write-Host "Already configured: $ConfigName"; return }
        if (-not $Force) { Write-Warning "Target exists; use -Force: $target"; return }
        Write-Host "Removing: $target"
        if (-not $DryRun) { Remove-Item -LiteralPath $target -Recurse -Force }
    }
    Write-Host "Linking: $target -> $source"
    if (-not $DryRun) {
        $parent = Split-Path -Parent $target
        if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    }
}

if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Manifest not found: $ManifestPath" }
Ensure-Yq

# Verify required package managers are available
$script:PackageManagers = Read-Yaml '.package_managers'
if ($PackageManagers) {
    foreach ($pmName in $PackageManagers.PSObject.Properties.Name) {
        $pm = Prop $PackageManagers $pmName
        $platform = Prop $pm 'platform'
        if ($platform -and $platform -ne 'windows') { continue }
        $check = Prop $pm 'check'
        if ($check -and -not (Get-Command ([string]$check) -ErrorAction SilentlyContinue)) {
            $hint = Prop $pm 'hint'
            if ($hint) { Write-Warning "[$pmName] $hint" } else { Write-Warning "Package manager '$pmName' not found ($check)." }
        }
    }
}

$script:Tools = Read-Yaml '.tools'
$script:Configs = Read-Yaml '.configs'
$script:Tags = Read-Yaml '.tags'
$toolNames = @($Tools.PSObject.Properties.Name)
$configNames = @($Configs.PSObject.Properties.Name)
$tagNames = @($Tags.PSObject.Properties.Name)

if ($List) {
    Write-Host 'Tools:'; foreach ($n in ($toolNames | Sort-Object)) { Write-Host "  $n - $(Prop (Prop $Tools $n) 'description')" }
    Write-Host 'Tags:'; foreach ($n in ($tagNames | Sort-Object)) { Write-Host "  $n - $(Prop $Tags $n)" }
    Write-Host 'Configs:'; foreach ($n in ($configNames | Sort-Object)) { Write-Host "  $n - $(Prop (Prop $Configs $n) 'description')" }
    exit 0
}

if ($All -or -not $Name -or $Name.Count -eq 0) { foreach ($n in $toolNames) { Select-Tool $n } }
else {
    foreach ($n in $Name) {
        if ($toolNames -contains $n) { Select-Tool $n }
        elseif ($tagNames -contains $n) { Select-Tag $n }
        else { throw "Unknown tool or tag: $n" }
    }
}

if ($Mode -ne 'ConfigureOnly') { foreach ($n in $toolNames) { if ($SelectedTools.ContainsKey($n)) { Install-Tool $n } } }
if ($Mode -ne 'InstallOnly') {
    if ($SelectedConfigs.Count -eq 0) { Write-Host 'No configs associated with the selection.' }
    foreach ($n in $configNames) { if ($SelectedConfigs.ContainsKey($n)) { Configure-Item $n } }
}
