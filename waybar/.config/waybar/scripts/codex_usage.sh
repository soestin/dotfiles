#!/usr/bin/env bash

set -euo pipefail

command -v jq >/dev/null || exit 0
command -v codexbar >/dev/null || exit 0

json="$(codexbar usage --json 2>/dev/null || true)"
[[ -n "$json" ]] || exit 0

data="$(
	printf '%s\n' "$json" \
		| jq -r '
			(first(.[]? | select(.provider == "codex")) // first(.[]?)) as $item
			| select($item != null)
			| ($item.usage.secondary // $item.usage.primary // $item.usage.tertiary) as $usage
			| select($usage != null and ($usage.usedPercent != null))
			| ($item.pace.secondary // $item.pace.primary // $item.pace.tertiary // {}) as $pace
			| [
				$usage.usedPercent,
				($usage.resetsAt // ""),
				($usage.resetDescription // ""),
				($item.usage.loginMethod // $item.usage.identity.loginMethod // ""),
				($item.usage.accountEmail // $item.usage.identity.accountEmail // ""),
				($pace.summary // ""),
				($item.usage.codexResetCredits.availableCount // 0),
				($item.version // "")
			]
			| @tsv
		' 2>/dev/null
)"

[[ -n "$data" ]] || exit 0

IFS=$'\t' read -r used_percent resets_at reset_description login_method account_email pace_summary reset_credits version <<< "$data"
[[ "$used_percent" =~ ^[0-9]+([.][0-9]+)?$ ]] || exit 0

used="$(LC_ALL=C awk -v value="$used_percent" 'BEGIN {printf "%.0f", value}')"
remaining=$(( 100 - used ))
if (( remaining < 0 )); then
	remaining=0
elif (( remaining > 100 )); then
	remaining=100
fi

class="normal"
if (( remaining <= 10 )); then
	class="critical"
elif (( remaining <= 25 )); then
	class="warning"
fi

tooltip="Codex weekly remaining: ${remaining}%"
tooltip="${tooltip}"$'\n'"Used: ${used}%"
if [[ -n "$reset_description" ]]; then
	tooltip="${tooltip}"$'\n'"Resets: ${reset_description}"
elif [[ -n "$resets_at" ]]; then
	reset_text="$(date -d "$resets_at" '+%a %d %b %H:%M' 2>/dev/null || true)"
	if [[ -n "$reset_text" ]]; then
		tooltip="${tooltip}"$'\n'"Resets: ${reset_text}"
	fi
fi
if [[ -n "$pace_summary" ]]; then
	tooltip="${tooltip}"$'\n'"Pace: ${pace_summary}"
fi
if [[ "$reset_credits" =~ ^[0-9]+$ && "$reset_credits" -gt 0 ]]; then
	tooltip="${tooltip}"$'\n'"Reset credits: ${reset_credits}"
fi
if [[ -n "$login_method" ]]; then
	tooltip="${tooltip}"$'\n'"Plan: ${login_method}"
fi
if [[ -n "$account_email" ]]; then
	tooltip="${tooltip}"$'\n'"Account: ${account_email}"
fi
if [[ -n "$version" ]]; then
	tooltip="${tooltip}"$'\n'"codexbar: ${version}"
fi

jq -cn --arg text "Codex ${remaining}%" --arg tooltip "$tooltip" --arg class "$class" \
	'{text: $text, tooltip: $tooltip, class: $class}'
