# dotfiles

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Fresh install

Assumes **CachyOS with the Hyprland ISO**.

```bash
git clone git@github.com:soestin/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Run with `-y` to skip all prompts:

```bash
./install.sh -y
```

The script will:
1. Install required packages via pacman/yay
2. Set Zsh as the default shell
3. Stow all dotfiles (creates symlinks into `~`)
4. Optionally install and configure `SilentSDDM` theme

Log out and back in after for the shell change to take effect.

On supported ASUS laptops, the installer also offers to enable Fn lock at boot
using `system/modprobe.d/asus-fnlock.conf`. Reboot after installing the setting.

## Packages managed

| Package | Contents |
|---|---|
| `home` | `.zshrc`, `.p10k.zsh`, `.gitconfig`, GTK dark-mode defaults |
| `hypr` | Hyprland, Hyprlock, Hyprpaper, Hypridle, scripts, wallpapers |
| `waybar` | Bar config and style |
| `wofi` | Launcher style |
| `wleave` | Logout menu |
| `fish` | Fish shell config |
| `fastfetch` | System info config |

## AirPods 4 ANC

The Waybar AirPods widget uses [airpods-tui](https://github.com/annoyedmilk/airpods-tui)
for battery status and Apple's noise-control protocol. Left-click opens a Wofi menu
for Noise Cancellation, Transparency, Adaptive, and Conversation Awareness.
Off appears when Off Listening Mode is enabled in the full settings. Right-click
opens all settings in a floating terminal, including ear detection and stem controls.
The bar shows separate left and right earbud batteries and the mode reported by the device;
hover for individual batteries. The case value is the last reported reading.
Only connected AirPods 4 ANC devices are displayed; the widget is hidden otherwise.

The Copilot key (Super+Shift+F23) connects your paired AirPods when disconnected. When connected, it toggles
ANC and Transparency (Adaptive or Off switches to ANC). Shift+F11 still toggles
fullscreen. The device address is configured as `AIRPODS_MAC` in the widget script.

`install.sh` offers the backend installation, or set it up separately:

```bash
yay -S --needed airpods-tui-bin
systemctl --user daemon-reload
systemctl --user enable --now airpods-tui.service
sudo systemctl restart bluetooth
```

The AUR package sets `DeviceID = bluetooth:004C:0000:0000` in
`/etc/bluetooth/main.conf` so the AirPods accept Apple's control protocol.
Restarting Bluetooth disconnects current Bluetooth devices. If already paired
AirPods refuse controls, forget and re-pair them after the change. On AirPods 4,
open the case and double-tap its front until the light flashes white.
Do not run LibrePods alongside this daemon; use one AirPods backend at a time.

The widget reconnects automatically when the daemon starts. If unavailable, check
`systemctl --user status airpods-tui` and `journalctl --user -u airpods-tui`.
The custom menu uses the daemon's internal JSON socket protocol, verified against
upstream on 2026-10-01; changes to that protocol may require updating `airpods.py`.

## SilentSDDM

`install.sh` can optionally install the [SilentSDDM](https://github.com/uiriansan/SilentSDDM) theme.

It will:
1. Ensure `yay` is installed (installs it with `pacman` if missing)
2. Install the theme from AUR (`sddm-silent-theme`, fallback `sddm-silent-theme-git`)
3. Update `/etc/sddm.conf` with:
   - `[General] InputMethod=qtvirtualkeyboard`
   - `[General] GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard`
   - `[Theme] Current=silent`

Test command:

```bash
QT_QUICK_BACKEND=software sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/silent
```

## Keybinds

| Keybind | Action |
|---|---|
| `SUPER + T` | Terminal (kitty) |
| `SUPER + B` | Browser (firefox) |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + A` | App launcher (wofi) |
| `SUPER + Q` | Close window |
| `SUPER + W` | Toggle floating |
| `SUPER + L` | Lock screen |
| `SUPER + V` | Clipboard history |
| `SUPER + O` | Toggle window transparency |
| `SUPER + G` | Toggle tab group for the active window |
| `ALT + Tab` | Next window in tab group |
| `SUPER + SHIFT + G` | Remove active window from tab group |
| `SUPER + /` | Keybinds hint |
| `SUPER + P` | Screenshot region → satty |
| `SUPER + CTRL + P` | Screenshot region (frozen) → satty |
| `SUPER + ALT + P` | Screenshot current monitor |
| `Print` | Screenshot all monitors |
| `SHIFT + FN + F11` | Fullscreen |
| `SUPER + 1-5` | Switch workspace |
| `SUPER + SHIFT + 1-5` | Move window to workspace |
| `SUPER + arrows` | Move focus |

### Hyprland Lua configuration

Hyprland 0.55+ loads `~/.config/hypr/hyprland.lua`. The previous configs are
preserved as `*.conf.pre-lua` backups, including local changes made before migration.
Hyprlock, Hypridle, and Hyprpaper still use their own `.conf` files.

The main config keeps the preferred-mode monitor fallback at scale 1.2.
`monitors.lua` contains the saved nwg-displays layout and `workspaces.lua` is
currently empty. Uncomment their `require` lines in `hyprland.lua` to use them.

Validate with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
Log out and back in once after migration so Hyprland selects the Lua config;
later Lua edits can be applied with `hyprctl reload`.
