# Define source and target directories

# $alacrittySource = Join-Path -Path $PSScriptRoot -ChildPath "alacritty"
# $alacrittyTarget = Join-Path -Path $env:APPDATA -ChildPath "alacritty"
$pwshSource = Join-Path -Path $PSScriptRoot -ChildPath "pwsh\Profile.ps1"
$pwshTarget = "$PROFILE"

$neovimSource = Join-Path -Path $PSScriptRoot -ChildPath "nvim"
$neovimTarget = Join-Path -Path $env:LOCALAPPDATA -ChildPath "nvim"

$weztermSource = Join-Path -Path $PSScriptRoot -ChildPath "wezterm\wezterm.lua"
$weztermTarget = Join-Path -Path $env:USERPROFILE -ChildPath ".wezterm.lua"

$starshipSource = Join-Path -Path $PSScriptRoot -ChildPath "starship\starship.toml"
$starshipTarget = Join-Path -Path $env:USERPROFILE -ChildPath ".config\starship.toml"

$yaziMainSource = Join-Path -Path $PSScriptRoot -ChildPath "yazi\yazi.toml"
$yaziMainTarget = Join-Path -Path $env:APPDATA -ChildPath "yazi\config\yazi.toml"
$yaziThemeSource = Join-Path -Path $PSScriptRoot -ChildPath "yazi\theme.toml"
$yaziThemeTarget = Join-Path -Path $env:APPDATA -ChildPath "yazi\config\theme.toml"
$yaziKeymapSource = Join-Path -Path $PSScriptRoot -ChildPath "yazi\keymap.toml"
$yaziKeymapTarget = Join-Path -Path $env:APPDATA -ChildPath "yazi\config\keymap.toml"

$gitSource = Join-Path -Path $PSScriptRoot -ChildPath "git\.gitconfig"
$gitTarget = Join-Path -Path $env:USERPROFILE -ChildPath ".gitconfig"

# Function to ensure parent directory exists
function Ensure-ParentDirectoryExists
{
    param (
        [string]$target
    )

    $parentDir = Split-Path -Path $target -Parent
    if (-not (Test-Path $parentDir))
    {
        New-Item -ItemType Directory -Path $parentDir | Out-Null
    }
}

# Function to create a symbolic link
function Create-SymbolicLink
{
    param (
        [string]$source,
        [string]$target
    )

    if (Test-Path $source)
    {
        Ensure-ParentDirectoryExists -target $target
        if (Test-Path $target)
        {
            Remove-Item -Path $target -Recurse -Force
        }
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Output "Created symbolic link from $target to $source"
    } else
    {
        Write-Output "$source does not exist."
    }
}

# Create symbolic links for Alacritty, Neovim, and WezTerm configurations
# Create-SymbolicLink -source $alacrittySource -target $alacrittyTarget
Create-SymbolicLink -source $neovimSource -target $neovimTarget
Create-SymbolicLink -source $weztermSource -target $weztermTarget
Create-SymbolicLink -source $starshipSource -target $starshipTarget

Create-SymbolicLink -source $yaziMainSource -target $yaziMainTarget
Create-SymbolicLink -source $yaziThemeSource -target $yaziThemeTarget
Create-SymbolicLink -source $yaziKeymapSource -target $yaziKeymapTarget

Create-SymbolicLink -source $pwshSource -target $pwshTarget

Create-SymbolicLink -source $gitSource -target $gitTarget

# Keep the terminal open
Read-Host -Prompt "Press Enter to exit"
