#!/bin/bash

# Screenshot script using grim + slurp + satty
# Modes:
#   s  - region select (opens in satty, only saves if you hit save)
#   sf - freeze screen, then region select (same)
#   m  - current monitor (saves directly + clipboard)
#   p  - all monitors (saves directly + clipboard)

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$SAVE_DIR/screenshot_${TIMESTAMP}.png"

MODE="${1:-s}"

case "$MODE" in
    s)
        # Pipe directly to satty — no file saved unless user hits save
        grim -g "$(slurp)" - | satty --filename - --output-filename "$FILE" --copy-command "wl-copy"
        ;;
    sf)
        # Freeze screen into temp file, select region, pipe to satty
        FREEZE_FILE="/tmp/freeze_$$.png"
        grim "$FREEZE_FILE"
        grim -g "$(slurp -r -b 1E1E2Eaa)" - < /dev/null
        grim -g "$(slurp)" - | satty --filename - --output-filename "$FILE" --copy-command "wl-copy"
        rm -f "$FREEZE_FILE"
        ;;
    m)
        # Current monitor — save directly and copy to clipboard
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
        grim -o "$MONITOR" "$FILE"
        wl-copy < "$FILE"
        notify-send "Screenshot" "Saved to $FILE" -i "$FILE"
        ;;
    p)
        # All monitors — save directly and copy to clipboard
        grim "$FILE"
        wl-copy < "$FILE"
        notify-send "Screenshot" "Saved to $FILE" -i "$FILE"
        ;;
    *)
        echo "Usage: screenshot.sh [s|sf|m|p]" >&2
        exit 1
        ;;
esac
