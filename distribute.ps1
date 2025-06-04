# Define source and target directories

# $alacrittySource = Join-Path -Path $PSScriptRoot -ChildPath "alacritty"
# $alacrittyTarget = Join-Path -Path $env:APPDATA -ChildPath "alacritty"
$symlinks = @(
    @{ source = "pwsh\Profile.ps1"; target = $PROFILE },
    @{ source = "nvim"; target = Join-Path $env:LOCALAPPDATA "nvim" },
    @{ source = "wezterm\wezterm.lua"; target = Join-Path $env:USERPROFILE ".wezterm.lua" },
    @{ source = "starship\starship.toml"; target = Join-Path $env:USERPROFILE ".config\starship.toml" },
    @{ source = "yazi\yazi.toml"; target = Join-Path $env:APPDATA "yazi\config\yazi.toml" },
    @{ source = "yazi\theme.toml"; target = Join-Path $env:APPDATA "yazi\config\theme.toml" },
    @{ source = "yazi\keymap.toml"; target = Join-Path $env:APPDATA "yazi\config\keymap.toml" },
    @{ source = "git\.gitconfig"; target = Join-Path $env:USERPROFILE ".gitconfig" }
)

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

function main
{
    foreach ($link in $symlinks)
    {
        $fullSource = Join-Path $PSScriptRoot $link.source
        Create-SymbolicLink -source $fullSource -target $link.target
    }

    Read-Host -Prompt "Press Enter to exit"
}

main
