# Define source and target directories
alacrittySource="$(pwd)/alacritty"
neovimSource="$(pwd)/nvim"
weztermSource="$(pwd)/wezterm/wezterm.lua"
starshipSource="$(pwd)/starship/starship.toml"

alacrittyTarget="$HOME/.config/alacritty"
neovimTarget="$HOME/.config/nvim"
weztermTarget="$HOME/.config/wezterm/wezterm.lua"
starshipTarget="$HOME/.config/starship.toml"

# Function to create a symbolic link
create_symbolic_link() {
    local source=$1
    local target=$2

    # Ensure the target directory exists
    mkdir -p "$(dirname "$target")"

    if [ -d "$source" ] || [ -f "$source" ]; then
        if [ -L "$target" ] || [ -e "$target" ]; then
            rm -rf "$target"  # Remove existing file/symlink/directory
        fi
        ln -s "$source" "$target"  # Create symbolic link
        echo "Created symbolic link from $target to $source"
    else
        echo "$source does not exist."
    fi
}

# Create symbolic links for Alacritty, Neovim, and WezTerm configurations
create_symbolic_link "$alacrittySource" "$alacrittyTarget"
create_symbolic_link "$neovimSource" "$neovimTarget"
create_symbolic_link "$weztermSource" "$weztermTarget"
create_symbolic_link "$starshipSource" "$starshipTarget"

# Keep the terminal open
read -p "Press Enter to exit"
