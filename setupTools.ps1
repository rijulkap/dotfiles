# Define the path to the JSON file
$jsonPath = "tools.json"

# Read the JSON file
if (Test-Path $jsonPath) {
    $tools = Get-Content $jsonPath | ConvertFrom-Json
} else {
    Write-Error "JSON file not found."
    exit 1
}

# Ensure Chocolatey is installed
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Chocolatey is not installed. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Function to install a tool using Chocolatey
function Install-Tool {
    param (
        [string]$tool,
        [array]$installCmds
    )
    
    if ($installCmds) {
        foreach ($cmd in $installCmds) {
            Invoke-Expression $cmd
        }
    } else {
        Write-Output "No installation instructions found for $tool on this OS."
    }
}

# Check for command line argument for a specific tool
param (
    [string]$single
)

if ($singleTool) {
    if ($tools.PSObject.Properties.Name -contains $single) {
        $installCmds = $tools.$single.Windows
        Install-Tool -tool $single -installCmds $installCmds
    } else {
        Write-Error "Tool '$single' not found in the list."
        exit 1
    }
} else {
    # Install all tools
    foreach ($tool in $tools.PSObject.Properties.Name) {
        $installCmds = $tools.$tool.Windows
        Install-Tool -tool $tool -installCmds $installCmds
        Write-Output "---------------------------------------------------------------------------------------"
    }
}

# Keep the terminal open if no specific tool was installed
if (-Not $single) {
    Read-Host -Prompt "Press Enter to exit"
}
