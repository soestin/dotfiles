#!/bin/bash

# Parse keybinds from hyprland.conf and show in wofi with search

grep "^bind" ~/.config/hypr/hyprland.conf | \
    sed 's/bind[a-z]* = //' | \
    awk -F',' '{
        mod = $1; key = $2; action = $3; arg = $4;
        gsub(/^ +| +$/, "", mod);
        gsub(/^ +| +$/, "", key);
        gsub(/^ +| +$/, "", action);
        gsub(/^ +| +$/, "", arg);
        if (arg != "")
            printf "%-30s %-15s %s %s\n", mod " + " key, "→", action, arg;
        else
            printf "%-30s %-15s %s\n", mod " + " key, "→", action;
    }' | \
    wofi --show dmenu \
         --prompt "Keybinds" \
         --width 800 \
         --height 500 \
         --no-actions \
         --insensitive
