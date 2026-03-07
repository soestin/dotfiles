#!/bin/bash

# Ensure a temporary file is created with a unique name and .png extension
# This variable will now hold the FULL PATH to the image file
TEMP_FILE="/tmp/hyprshot_edit_$(date +%s)_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1).png"

# Extract directory and filename from TEMP_FILE
OUTPUT_DIR=$(dirname "$TEMP_FILE")
OUTPUT_BASENAME=$(basename "$TEMP_FILE")

# Take screenshot using hyprshot
# Use --output-folder for the directory and --filename for the exact filename
hyprshot -m "$1" --output-folder "$OUTPUT_DIR" --filename "$OUTPUT_BASENAME"

# Check if the screenshot was actually created
if [ -f "$TEMP_FILE" ]; then
    # Open the temporary file with swappy
    /usr/bin/swappy -f "$TEMP_FILE"

    # After swappy exits, remove the temporary file
    rm "$TEMP_FILE"
else
    echo "Failed to capture screenshot at $TEMP_FILE." >&2
    notify-send "Hyprshot Error" "Failed to capture screenshot for editing."
fi
