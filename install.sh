#!/bin/bash
# Usage: ./install.sh [--yes|-y]

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTO=false
[[ "$1" == "--yes" || "$1" == "-y" ]] && AUTO=true

ask() {
    $AUTO && return 0
    read -rp "$1 [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

# 1. Install packages
if ask "Install required packages?"; then
    yay -S --needed \
        stow \
        cachyos-zsh-config \
        wleave \
        networkmanager-dmenu
fi

# 2. Set Zsh as default shell
if ask "Set Zsh as default shell?"; then
    chsh -s "$(which zsh)"
fi

# 3. Stow dotfiles
if ask "Stow dotfiles?"; then
    cd "$DOTFILES_DIR"
    stow --adopt home hypr waybar wofi wleave fish fastfetch networkmanager-dmenu
    git restore .
fi

echo "Done. Log out and back in for shell change to take effect."
