#!/bin/bash
# Usage: ./install.sh [--yes|-y]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTO=false
# Use parameter expansion to avoid 'unbound variable' error
[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && AUTO=true

ask() {
    $AUTO && return 0
    # Use || true to prevent set -e from killing the script if read fails or is interrupted
    read -rp "$1 [y/N] " ans || return 1
    [[ "$ans" =~ ^[Yy]$ ]]
}

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        return 0
    fi

    echo "yay not found. Installing yay via pacman..."
    sudo pacman -S --needed yay
}

install_silent_sddm_theme() {
    if ! ensure_yay; then
        echo "Failed to install yay; cannot install SilentSDDM theme." >&2
        return 1
    fi

    if yay -S --needed sddm-silent-theme; then
        return 0
    fi

    echo "Falling back to sddm-silent-theme-git..."
    yay -S --needed sddm-silent-theme-git
}

set_ini_value() {
    local file="$1"
    local section="$2"
    local key="$3"
    local value="$4"
    local tmp

    tmp="$(mktemp)"

    if [[ -f "$file" ]]; then
        awk -v section="$section" -v key="$key" -v value="$value" '
            BEGIN {
                in_section = 0
                section_found = 0
                key_set = 0
            }

            /^\[[^]]+\]$/ {
                if (in_section && !key_set) {
                    print key "=" value
                    key_set = 1
                }

                in_section = ($0 == "[" section "]")
                if (in_section) {
                    section_found = 1
                }
            }

            {
                if (in_section && $0 ~ "^" key "=") {
                    print key "=" value
                    key_set = 1
                    next
                }
                print
            }

            END {
                if (!section_found) {
                    print "[" section "]"
                    print key "=" value
                } else if (in_section && !key_set) {
                    print key "=" value
                }
            }
        ' "$file" > "$tmp"
    else
        printf "[%s]\n%s=%s\n" "$section" "$key" "$value" > "$tmp"
    fi

    sudo install -Dm644 "$tmp" "$file"
    rm -f "$tmp"
}

# 1. Install packages
if ask "Install required packages?"; then
    sudo pacman -S --needed \
        stow \
        hyprland \
        hyprpaper \
        hyprlock \
        hypridle \
        waybar \
        wofi \
        swaync \
        kitty \
        firefox \
        dolphin \
        cliphist \
        wl-clipboard \
        brightnessctl \
        playerctl \
        pwvucontrol \
        wireplumber \
        networkmanager \
        network-manager-applet \
        libnotify \
        fish \
        fastfetch \
        zsh \
        oh-my-zsh-git \
        zsh-theme-powerlevel10k \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        zsh-history-substring-search \
        pkgfile \
        fzf \
        grim \
        slurp \
        satty \
        jq \
        python \
        gcc \
        pkgconf \
        git \
        meson \
        ninja \
        glib2-devel

    # AUR packages
    if ! ensure_yay; then
        echo "Failed to install yay; cannot continue with AUR package installation." >&2
        exit 1
    fi
    yay -S --needed \
        wleave
fi

# Optional AirPods 4 ANC controls and battery daemon.
if ask "Install AirPods controls (sets Apple's Bluetooth DeviceID)?"; then
    ensure_yay
    yay -S --needed airpods-tui-bin
    systemctl --user daemon-reload
    systemctl --user enable --now airpods-tui.service
    echo "Restart Bluetooth and re-pair your AirPods if noise controls remain unavailable."
fi

# 2. Set Zsh as default shell
if ask "Set Zsh as default shell?"; then
    chsh -s "$(which zsh)"
fi

# 3. Stow dotfiles
if ask "Stow dotfiles?"; then
    cd "$DOTFILES_DIR"
    stow --adopt home hypr waybar wofi wleave fish fastfetch
    git restore .
    ~/.config/waybar/scripts/build-nm-waybar.sh
fi

# 4. Optional SilentSDDM install
if ask "Install SilentSDDM theme?"; then
    if install_silent_sddm_theme; then
        set_ini_value "/etc/sddm.conf" "General" "InputMethod" "qtvirtualkeyboard"
        set_ini_value "/etc/sddm.conf" "General" "GreeterEnvironment" "QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard"
        set_ini_value "/etc/sddm.conf" "Theme" "Current" "silent"
        echo "SilentSDDM theme installed and /etc/sddm.conf updated."
    else
        echo "Failed to install SilentSDDM theme package." >&2
    fi
fi

# Persist Fn lock on ASUS laptops with driver support.
if [[ -e /sys/module/asus_wmi/parameters/fnlock_default ]] && ask "Enable ASUS Fn lock at startup?"; then
    sudo install -Dm644 "$DOTFILES_DIR/system/modprobe.d/asus-fnlock.conf" "/etc/modprobe.d/asus-fnlock.conf"
    echo "ASUS Fn lock enabled for subsequent boots."
fi

echo "Done. Log out and back in for shell change to take effect."
