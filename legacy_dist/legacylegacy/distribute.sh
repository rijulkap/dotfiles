#!/bin/bash

set -e  # Exit on error

# Root of your dotfiles (e.g., repo root)
ROOT="$(pwd)"

# Define source and target pairs as tuples: "source -> target"
declare -a SYMLINKS=(
    "$ROOT/fish/config.fish -> $HOME/.config/fish/config.fish"
    "$ROOT/nvim -> $HOME/.config/nvim"
    "$ROOT/wezterm/wezterm.lua -> $HOME/.config/wezterm/wezterm.lua"
    "$ROOT/starship/starship.toml -> $HOME/.config/starship.toml"
    "$ROOT/yazi/yazi.toml -> $HOME/.config/yazi/yazi.toml"
    "$ROOT/yazi/theme.toml -> $HOME/.config/yazi/theme.toml"
    "$ROOT/yazi/keymap.toml -> $HOME/.config/yazi/keymap.toml"
    "$ROOT/git/.gitconfig -> $HOME/.gitconfig"
)

# Create symbolic link safely
create_symbolic_link() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        echo "⚠️  $source does not exist. Skipping."
        return
    fi

    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" || -e "$target" ]]; then
        echo "🗑️  Removing existing $target"
        rm -rf "$target"
    fi

    ln -s "$source" "$target"
    echo "✅ Linked: $target → $source"
}

# Loop through all path pairs
for pair in "${SYMLINKS[@]}"; do
    src="${pair%% -> *}"
    tgt="${pair##* -> }"
    create_symbolic_link "$src" "$tgt"
done

read -p "Press Enter to exit"
