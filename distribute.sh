#!/bin/bash

# Define source and target directories

# alacrittySource="$(pwd)/alacritty"
# alacrittyTarget="$HOME/.config/alacritty"
fishSource="$(pwd)/fish/config.fish"
fishTarget="$HOME/.config/fish/config.fish"

neovimSource="$(pwd)/nvim"
neovimTarget="$HOME/.config/nvim"

weztermSource="$(pwd)/wezterm/wezterm.lua"
weztermTarget="$HOME/.config/wezterm/wezterm.lua"

starshipSource="$(pwd)/starship/starship.toml"
starshipTarget="$HOME/.config/starship.toml"

yaziMainSource="$(pwd)/yazi/yazi.toml"
yaziMainTarget="$HOME/.config/yazi/yazi.toml"
yaziThemeSource="$(pwd)/yazi/theme.toml"
yaziThemeTarget="$HOME/.config/yazi/theme.toml"
yaziKeymapSource="$(pwd)/yazi/keymap.toml"
yaziKeymapTarget="$HOME/.config/yazi/keymap.toml"


gitSource="$(pwd)/git/.gitconfig"
gitTarget="$HOME/.gitconfig"

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
# create_symbolic_link "$alacrittySource" "$alacrittyTarget"
create_symbolic_link "$neovimSource" "$neovimTarget"
create_symbolic_link "$weztermSource" "$weztermTarget"
create_symbolic_link "$starshipSource" "$starshipTarget"

create_symbolic_link "$yaziMainSource" "$yaziMainTarget"
create_symbolic_link "$yaziThemeSource" "$yaziThemeTarget"
create_symbolic_link "$yaziKeymapSource" "$yaziKeymapTarget"

create_symbolic_link "$fishSource" "$fishTarget"

create_symbolic_link "$gitSource" "$gitTarget"

# Keep the terminal open
read -p "Press Enter to exit"
