#!/usr/bin/env bash

set -euo pipefail

cpu_raw="$(top -bn1 | awk '/^%Cpu\(s\):/ {print $2+$4; exit}')"
cpu="${cpu_raw%%.*}"

mem_line="$(free -m | awk '/^Mem:/ {print $2, $3; exit}')"
mem_total="$(awk '{print $1}' <<< "$mem_line")"
mem_used="$(awk '{print $2}' <<< "$mem_line")"
mem_pct=$(( mem_used * 100 / mem_total ))

read -r disk_pct disk_used disk_total < <(df -h / | awk 'NR==2 {gsub(/%/, "", $5); print $5, $3, $2}')

text=" ${cpu}%   ${mem_pct}%  󰋊 ${disk_pct}%"
tooltip="CPU: ${cpu}%\nMEM: ${mem_used}MiB / ${mem_total}MiB (${mem_pct}%)\nDISK(/): ${disk_used} / ${disk_total} (${disk_pct}%)"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
