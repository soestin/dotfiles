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

Log out and back in after for the shell change to take effect.

## Packages managed

| Package | Contents |
|---|---|
| `home` | `.zshrc`, `.gitconfig` |
| `hypr` | Hyprland, Hyprlock, Hyprpaper, Hypridle, scripts, wallpapers |
| `waybar` | Bar config and style |
| `wofi` | Launcher style |
| `wleave` | Logout menu |
| `fish` | Fish shell config |
| `fastfetch` | System info config |
| `networkmanager-dmenu` | Network manager config |

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
