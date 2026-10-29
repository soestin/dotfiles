#!/usr/bin/env bash
# Build the pinned Waybar release with isolated applet modules and icon tinting.
set -euo pipefail
config_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
build_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-nm"
install_dir="${XDG_DATA_HOME:-$HOME/.local/share}/waybar-nm"
mkdir -p "$build_dir" "$install_dir"
if [[ ! -d "$build_dir/source/.git" ]]; then
    git clone --depth 1 --branch 0.15.0 https://github.com/Alexays/Waybar.git "$build_dir/source"
fi
# Use a clean, separate checkout; never reset the user's dotfiles.
source_dir=$(mktemp -d "$build_dir/source.XXXXXXXX")
git -C "$build_dir/source" archive 90b209add8937514d0a987aa842e701bd8f1232e | tar -x -C "$source_dir"
git -C "$source_dir" apply "$config_dir/patches/nm-applet.patch"
meson setup "$source_dir/build" "$source_dir" -Dbuildtype=release -Dtests=disabled -Dman-pages=disabled -Dcava=disabled
meson compile -C "$source_dir/build" -j 4
install -m 755 "$source_dir/build/waybar" "$install_dir/waybar.new"
mv "$install_dir/waybar.new" "$install_dir/waybar"
printf 'Installed applet-enabled Waybar to %s/waybar\n' "$install_dir"
