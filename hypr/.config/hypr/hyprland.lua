-- Hyprland Lua configuration (0.55+).
-- Monitor/workspace files are managed by nwg-displays; enable them below if desired.

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.2 })
-- These were not sourced by the previous config. Uncomment to use the saved display layout.
-- require("monitors")
-- require("workspaces")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.config({
    ["cursor.no_hardware_cursors"] = false,
    ["xwayland.force_zero_scaling"] = true,
    ["general.gaps_in"] = 1,
    ["general.gaps_out"] = 4,
    ["general.border_size"] = 1,
    ["general.col.active_border"] = "rgba(b87950cc)",
    ["general.col.inactive_border"] = "rgba(2a2a2acc)",
    ["general.resize_on_border"] = false,
    ["general.allow_tearing"] = false,
    ["general.layout"] = "dwindle",
    ["decoration.rounding"] = 0,
    ["decoration.rounding_power"] = 2,
    ["decoration.active_opacity"] = 0.97,
    ["decoration.inactive_opacity"] = 0.93,
    ["decoration.shadow.enabled"] = true,
    ["decoration.shadow.range"] = 12,
    ["decoration.shadow.render_power"] = 3,
    ["decoration.shadow.color"] = "rgba(00000088)",
    ["decoration.blur.enabled"] = true,
    ["decoration.blur.size"] = 4,
    ["decoration.blur.passes"] = 2,
    ["decoration.blur.vibrancy"] = 0.08,
    ["group.auto_group"] = false,
    ["group.col.border_active"] = "rgba(b87950cc)",
    ["group.col.border_inactive"] = "rgba(2a2a2acc)",
    ["group.groupbar.enabled"] = true,
    ["group.groupbar.gradients"] = true,
    ["group.groupbar.render_titles"] = true,
    ["group.groupbar.scrolling"] = true,
    ["group.groupbar.height"] = 18,
    ["group.groupbar.font_size"] = 11,
    ["group.groupbar.indicator_height"] = 2,
    ["group.groupbar.gaps_in"] = 0,
    ["group.groupbar.gaps_out"] = 0,
    ["group.groupbar.text_padding"] = 4,
    ["group.groupbar.col.active"] = "rgba(b8795044)",
    ["group.groupbar.col.inactive"] = "rgba(151515aa)",
    ["group.groupbar.text_color"] = "rgba(fafafaff)",
    ["animations.enabled"] = true,
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
hl.config({
    ["dwindle.preserve_split"] = true,
    ["master.new_status"] = "master",
    ["misc.force_default_wallpaper"] = -1,
    ["misc.disable_hyprland_logo"] = false,
    ["input.kb_layout"] = "us",
    ["input.kb_variant"] = "",
    ["input.kb_model"] = "",
    ["input.kb_options"] = "",
    ["input.kb_rules"] = "",
    ["input.follow_mouse"] = 1,
    ["input.sensitivity"] = 0,
    ["input.touchpad.natural_scroll"] = true,
    ["input.touchpad.disable_while_typing"] = false,
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + B", hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("wofi --show drun --hide-scroll"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh s"))
hl.bind("SUPER + CTRL + P", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh sf"))
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh m"))
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/Scripts/screenshot.sh p"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("bash ~/.config/hypr/Scripts/clipboard.sh"))
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + F23", hl.dsp.exec_cmd("flock -n /run/user/$(id -u)/airpods-hotkey.lock python3 ~/.config/waybar/scripts/airpods.py hotkey"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("~/.config/hypr/Scripts/opacity_toggle.sh"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd("~/.config/hypr/Scripts/keybinds_hint.sh"))
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = true }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = true }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = true }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = true }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = true }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = true }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = true }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = true }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = true }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = true }))
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = true }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + X", hl.dsp.window.resize(), { mouse = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.window_rule({
    match = { ["class"] = "com.saivert.pwvucontrol" },
    name = "pwvucontrol-float",
    float = true,
})

-- Keep Zen picture-in-picture above apps within its own workspace.
hl.window_rule({
    match = { ["class"] = "^(app\\.zen_browser\\.zen|zen|zen-browser)$", ["title"] = "^Picture-in-Picture$" },
    name = "zen-pip-always-on-top",
    float = true,
    pin = false,
})

local raisingZenPip = false
local function raiseZenPip()
    if raisingZenPip then return end
    raisingZenPip = true
    for _, w in ipairs(hl.get_windows()) do
        if (w.class == "app.zen_browser.zen" or w.class == "zen" or w.class == "zen-browser")
            and w.title == "Picture-in-Picture" and w.mapped and w.floating
            and w.workspace and w.monitor and w.monitor.active_workspace
            and w.workspace.id == w.monitor.active_workspace.id then
            hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = w }))
        end
    end
    raisingZenPip = false
end
hl.on("window.active", raiseZenPip)
hl.on("window.open", raiseZenPip)
hl.on("window.fullscreen", raiseZenPip)
hl.on("workspace.active", raiseZenPip)
hl.on("config.reloaded", raiseZenPip)

hl.window_rule({
    match = { ["class"] = "airpods-settings" },
    name = "airpods-settings-float",
    float = true,
    center = true,
    size = "850 620",
})

hl.window_rule({
    match = { ["class"] = "com.gabm.satty" },
    name = "satty-float",
    float = true,
})

hl.window_rule({
    match = { ["workspace"] = "special:magic" },
    name = "scratchpad-opacity",
    opacity = "0.82 0.72",
})

hl.window_rule({
    match = { ["class"] = "^(Spotify|spotify|com.spotify.Client)$" },
    name = "spotify-scratchpad",
    workspace = "special:magic",
})

hl.window_rule({
    match = { ["class"] = ".*" },
    name = "suppress-maximize-events",
    suppress_event = "maximize",
})

hl.window_rule({
    match = { ["class"] = "^$", ["title"] = "^$", ["xwayland"] = true, ["float"] = true, ["fullscreen"] = false, ["pin"] = false },
    name = "fix-xwayland-drags",
    no_focus = true,
})

hl.window_rule({
    match = { ["class"] = "hyprland-run" },
    name = "move-hyprland-run",
    move = "20 monitor_h-120",
    float = true,
})


-- Run startup commands once, rather than on every config reload.
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch timeout --kill-after=2s 5s cliphist store")
    hl.exec_cmd("wl-paste --type image --watch timeout --kill-after=2s 5s cliphist store")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("bash -c 'while true; do pgrep -x waybar >/dev/null || ~/.config/waybar/scripts/start-waybar.sh; sleep 2; done'")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/Scripts/mute_on_startup.sh")
    hl.exec_cmd("~/.config/hypr/Scripts/battery_monitor.sh")
    hl.exec_cmd("nm-applet --indicator")
end)
