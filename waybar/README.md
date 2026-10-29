# Waybar network applet

Wi-Fi runs as `tray#wifi`, directly left of `battery`. It hosts the real
`nm-applet --indicator`, so network selection, password prompts, settings,
tooltips, and changing connection icons remain NetworkManager's own behavior.
The icon is tinted `#f97316`; the normal tray excludes only nm-applet.

This requires a locally built Waybar 0.15.0 with the small patch in
`.config/waybar/patches/nm-applet.patch`. The system Waybar package is untouched.
Hyprland launches `.config/waybar/scripts/start-waybar.sh`, which uses
`~/.local/share/waybar-nm/waybar` (or `$XDG_DATA_HOME/waybar-nm/waybar`).

## Rebuild

Install build dependencies (`meson`, `ninja`, `glib2-devel`, a C++ compiler,
`pkgconf`, and Waybar's development dependencies), then run:

```sh
~/.config/waybar/scripts/build-nm-waybar.sh
pkill -x waybar
```

The existing Hyprland supervisor restarts the bar. On this machine the installed
Waybar dependencies already supply the headers; initial build tools were staged
in `/tmp`, without installing system packages.

The patch adds per-tray `include-items` and `exclude-items` substring filters on
the registered D-Bus service/path, plus `icon-color` tinting that preserves the
original icon's alpha and shape. Other tray apps retain their original icons.
Rebuild after library ABI changes; system package updates do not update this
local binary. Upgrading Waybar requires reviewing/rebasing the pinned patch.

`networkmanager-dmenu` configuration and install references have been removed.
If its package is still installed, remove it with
`sudo pacman -R networkmanager-dmenu`.
