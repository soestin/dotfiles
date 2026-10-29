#!/usr/bin/env bash
set -euo pipefail
binary="${XDG_DATA_HOME:-$HOME/.local/share}/waybar-nm/waybar"
if [[ ! -x "$binary" ]]; then
    printf 'Build the applet-enabled Waybar first: ~/.config/waybar/scripts/build-nm-waybar.sh\n' >&2
    exit 1
fi
exec "$binary" "$@"
