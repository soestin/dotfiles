#!/bin/bash
set -euo pipefail

clear_label='[Clear clipboard history]'

selection=$(
  {
    cliphist list
    printf '%s\n' "$clear_label"
  } | wofi --show dmenu --hide-scroll --prompt 'Clipboard' --cache-file /dev/null
)

[[ -z "${selection:-}" ]] && exit 0

if [[ "$selection" == "$clear_label" ]]; then
  cliphist wipe
  wl-copy --clear
  exit 0
fi

printf '%s' "$selection" | cliphist decode | wl-copy
