#!/bin/bash

# Mergem în folderul unde se află scriptul
cd "$(dirname "$0")"

# Pachetele pe care vrem să le activăm
apps=(
    dunst
    hypr
    nvim
    rofi
    starship
    wallpapers
    waybar
    waypaper
)

echo "Stowing apps..."
for app in "${apps[@]}"; do
    stow "$app"
done

echo "Done! ✨"
