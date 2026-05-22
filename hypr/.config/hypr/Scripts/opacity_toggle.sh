#!/bin/bash

# Toggle window transparency on/off
# On: 0.95, Off: 1.0

CURRENT=$(hyprctl getoption decoration:active_opacity | awk '/float/ {print $2}')

if awk "BEGIN {exit !($CURRENT < 1.0)}"; then
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
else
    hyprctl keyword decoration:active_opacity 0.95
    hyprctl keyword decoration:inactive_opacity 0.95
fi
