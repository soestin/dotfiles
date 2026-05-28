#!/bin/bash

# Wait briefly for PipeWire/WirePlumber to expose the default sink, then mute it.
for _ in {1..20}; do
    if wpctl status >/dev/null 2>&1; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
        exit 0
    fi

    sleep 0.5
done

exit 1
