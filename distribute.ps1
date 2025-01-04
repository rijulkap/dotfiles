# Define source and target directories
$alacrittySource = Join-Path -Path $PSScriptRoot -ChildPath "alacritty"
$neovimSource = Join-Path -Path $PSScriptRoot -ChildPath "nvim"
$weztermSource = Join-Path -Path $PSScriptRoot -ChildPath "wezterm\wezterm.lua"

$alacrittyTarget = Join-Path -Path $env:APPDATA -ChildPath "alacritty"
$neovimTarget = Join-Path -Path $env:LOCALAPPDATA -ChildPath "nvim"
$weztermTarget = Join-Path -Path $env:USERPROFILE -ChildPath ".wezterm.lua"

# Function to ensure parent directory exists
function Ensure-ParentDirectoryExists {
    param (
        [string]$target
    )

    $parentDir = Split-Path -Path $target -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir | Out-Null
    }
}

# Function to create a symbolic link
function Create-SymbolicLink {
    param (
        [string]$source,
        [string]$target
    )

    if (Test-Path $source) {
        Ensure-ParentDirectoryExists -target $target
        if (Test-Path $target) {
            Remove-Item -Path $target -Recurse -Force
        }
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Output "Created symbolic link from $target to $source"
    } else {
        Write-Output "$source does not exist."
    }
}

# Create symbolic links for Alacritty, Neovim, and WezTerm configurations
Create-SymbolicLink -source $alacrittySource -target $alacrittyTarget
Create-SymbolicLink -source $neovimSource -target $neovimTarget
Create-SymbolicLink -source $weztermSource -target $weztermTarget

# Keep the terminal open
Read-Host -Prompt "Press Enter to exit"
