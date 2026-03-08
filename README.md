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
| `networkmanager-dmenu` | Network manager config |

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
| `SUPER + G` | Toggle window transparency |
| `SUPER + /` | Keybinds hint |
| `SUPER + P` | Screenshot region → satty |
| `SUPER + CTRL + P` | Screenshot region (frozen) → satty |
| `SUPER + ALT + P` | Screenshot current monitor |
| `Print` | Screenshot all monitors |
| `SHIFT + FN + F11` | Fullscreen |
| `SUPER + 1-5` | Switch workspace |
| `SUPER + SHIFT + 1-5` | Move window to workspace |
| `SUPER + arrows` | Move focus |
