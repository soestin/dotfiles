#!/bin/bash

# Toggle window transparency on/off through the Lua configuration API.
hyprctl eval '
    local opacity = hl.get_config("decoration.active_opacity")
    local target = opacity < 1.0 and 1.0 or 0.95
    hl.config({ decoration = { active_opacity = target, inactive_opacity = target } })
'
