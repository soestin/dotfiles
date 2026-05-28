#!/usr/bin/env bash

set -euo pipefail

player="spotify"
cache_file="/tmp/waybar-songdetail-${player}.cache"
grace_seconds=5
now="$(date +%s)"

status="$(playerctl --player="$player" status 2>/dev/null || true)"

show_cached() {
	if [[ ! -f "$cache_file" ]]; then
		exit 0
	fi

	local last_seen cached_text age
	last_seen="$(sed -n '1p' "$cache_file" 2>/dev/null || true)"
	cached_text="$(sed -n '2p' "$cache_file" 2>/dev/null || true)"

	[[ "$last_seen" =~ ^[0-9]+$ ]] || exit 0
	[[ -n "$cached_text" ]] || exit 0

	age=$(( now - last_seen ))
	(( age <= grace_seconds )) || exit 0

	printf '%s\n' "$cached_text"
}

case "$status" in
	Playing)
		title="$(playerctl --player="$player" metadata xesam:title 2>/dev/null || true)"
		artist="$(playerctl --player="$player" metadata xesam:artist 2>/dev/null || true)"
		[[ -n "${title}${artist}" ]] || exit 0

		text=" ${title}"
		if [[ -n "$artist" ]]; then
			text="${text}  ${artist}"
		fi

		printf '%s\n%s\n' "$now" "$text" > "$cache_file"
		printf '%s\n' "$text"
		;;
	Paused|Stopped|"")
		show_cached
		;;
	*)
		exit 0
		;;
esac
