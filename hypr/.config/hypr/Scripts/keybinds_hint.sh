#!/bin/bash
set -o pipefail

# Read registered keybinds so this works with Lua configs and included modules.
hyprctl -j binds | jq -r '
    def modifiers:
        . as $mask |
        [[1, "SHIFT"], [4, "CTRL"], [8, "ALT"], [64, "SUPER"]]
        | map(select(($mask / .[0] | floor % 2) == 1) | .[1])
        | join(" + ");
    .[] |
    ((.modmask | modifiers) as $mod |
        (if $mod == "" then .key else $mod + " + " + .key end)) +
    " → " + .dispatcher +
    (if .arg == "" then "" else " " + .arg end)
' | wofi --show dmenu          --prompt "Keybinds"          --width 800          --height 500          --no-actions          --insensitive
