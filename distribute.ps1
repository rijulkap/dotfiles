# Define source and target directories
$alacrittySource = Join-Path -Path $PSScriptRoot -ChildPath "alacritty"
$neovimSource = Join-Path -Path $PSScriptRoot -ChildPath "nvim"
$weztermSource = Join-Path -Path $PSScriptRoot -ChildPath "wezterm\\.wezterm.lua"

$alacrittyTarget = "$env:APPDATA\alacritty"
$neovimTarget = "$env:LOCALAPPDATA\nvim"
$weztermTarget = "$env:HOME\.wezterm.lua"

# Function to create a symbolic link
function Create-SymbolicLink {
    param (
        [string]$source,
        [string]$target
    )

    if (Test-Path $source) {
        if (Test-Path $target) {
            Remove-Item -Path $target -Recurse -Force
        }
        New-Item -ItemType SymbolicLink -Path $target -Target $source
        Write-Output "Created symbolic link from $target to $source"
    } else {
        Write-Output "$source does not exist."
    }
}

# Create symbolic links for Alacritty and Neovim configuration folders
Create-SymbolicLink -source $alacrittySource -target $alacrittyTarget
Create-SymbolicLink -source $neovimSource -target $neovimTarget
Create-SymbolicLink -source $weztermSource -target $weztermTarget

# Keep the terminal open
Read-Host -Prompt "Press Enter to exit"
