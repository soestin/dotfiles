#!/bin/bash

set -u

readonly WARNING_ICON="battery-caution"
readonly CRITICAL_ICON="battery-empty"
readonly SHUTDOWN_SECONDS=120
readonly WARNING_NOTIFICATION_ID=42001

warned_15=0
warned_10=0
warned_5=0
countdown_notification_id=""

find_batteries() {
    find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' 2>/dev/null | sort
}

read_battery_state() {
    local batteries
    local battery
    local status
    local capacity
    local total=0
    local count=0
    local discharging=0
    local charging=0

    batteries="$(find_batteries)"
    [[ -n "$batteries" ]] || return 1

    while IFS= read -r battery; do
        [[ -n "$battery" ]] || continue
        [[ -r "$battery/capacity" && -r "$battery/status" ]] || continue

        capacity="$(<"$battery/capacity")"
        status="$(<"$battery/status")"

        total=$((total + capacity))
        count=$((count + 1))

        case "$status" in
            Discharging)
                discharging=1
                ;;
            Charging|Full|Not\ charging|Unknown)
                charging=1
                ;;
        esac
    done <<< "$batteries"

    [[ "$count" -gt 0 ]] || return 1

    printf '%s %s %s\n' "$((total / count))" "$discharging" "$charging"
}

send_warning() {
    local level="$1"

    notify-send \
        -a "Battery Monitor" \
        -u critical \
        -i "$WARNING_ICON" \
        -r "$WARNING_NOTIFICATION_ID" \
        "Battery at ${level}%" \
        "Plug in your charger."
}

start_shutdown_countdown() {
    local remaining="$SHUTDOWN_SECONDS"
    local capacity
    local discharging
    local charging
    local state
    local notify_cmd

    countdown_notification_id=""

    while [[ "$remaining" -gt 0 ]]; do
        if ! state="$(read_battery_state)"; then
            sleep 1
            remaining=$((remaining - 1))
            continue
        fi

        read -r capacity discharging charging <<< "$state"

        if [[ "$discharging" -eq 0 || "$charging" -eq 1 ]]; then
            notify_cmd=(
                notify-send
                -p
                -a "Battery Monitor"
                -u normal
                -i "$WARNING_ICON"
            )
            [[ -n "$countdown_notification_id" ]] && notify_cmd+=(-r "$countdown_notification_id")
            countdown_notification_id="$("${notify_cmd[@]}" \
                "Shutdown cancelled" \
                "Power was connected before the shutdown timer ended." 2>/dev/null || true)"
            return 0
        fi

        notify_cmd=(
            notify-send
            -p
            -a "Battery Monitor"
            -u critical
            -i "$CRITICAL_ICON"
            -t 0
        )
        [[ -n "$countdown_notification_id" ]] && notify_cmd+=(-r "$countdown_notification_id")
        countdown_notification_id="$("${notify_cmd[@]}" \
            "Shutdown in ${remaining}s" \
            "Battery is at ${capacity}%. Connect power now or the PC will shut down." 2>/dev/null || true)"

        sleep 1
        remaining=$((remaining - 1))
    done

    systemctl poweroff
}

while true; do
    if ! state="$(read_battery_state)"; then
        sleep 30
        continue
    fi

    read -r capacity discharging charging <<< "$state"

    if [[ "$discharging" -eq 1 && "$charging" -eq 0 ]]; then
        if [[ "$capacity" -le 15 && "$warned_15" -eq 0 ]]; then
            send_warning 15
            warned_15=1
        fi

        if [[ "$capacity" -le 10 && "$warned_10" -eq 0 ]]; then
            send_warning 10
            warned_10=1
        fi

        if [[ "$capacity" -le 5 && "$warned_5" -eq 0 ]]; then
            send_warning 5
            warned_5=1
            start_shutdown_countdown
        fi
    fi

    if [[ "$charging" -eq 1 || "$capacity" -gt 15 ]]; then
        warned_15=0
        warned_10=0
        warned_5=0
    elif [[ "$capacity" -gt 10 ]]; then
        warned_10=0
        warned_5=0
    elif [[ "$capacity" -gt 5 ]]; then
        warned_5=0
    fi

    sleep 30
done
