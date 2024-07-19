# Define source and target directories
alacrittySource="$(pwd)/alacritty"
neovimSource="$(pwd)/nvim"

alacrittyTarget="$HOME/.config/alacritty"
neovimTarget="$HOME/.config/nvim"

# Function to create a symbolic link
create_symbolic_link() {
    local source=$1
    local target=$2

    if [ -d "$source" ]; then
        if [ -L "$target" ] || [ -e "$target" ]; then
            rm -rf "$target"
        fi
        ln -s "$source" "$target"
        echo "Created symbolic link from $target to $source"
    else
        echo "$source does not exist."
    fi
}

# Create symbolic links for Alacritty and Neovim configuration folders
create_symbolic_link "$alacrittySource" "$alacrittyTarget"
create_symbolic_link "$neovimSource" "$neovimTarget"

# Keep the terminal open
read -p "Press Enter to exit"