#!/bin/bash

# 1. Definirea căii (folosind variabila $HOME pentru portabilitate)
WALL="$HOME/.config/wallpapers/castel.jpeg"

# 2. Restart hyprpaper
pkill hyprpaper
hyprpaper &

# Așteptăm puțin să pornească procesul
sleep 1

# 3. Preload la imagine (obligatoriu înainte de a o seta)
hyprctl hyprpaper preload "$WALL"

# 4. Magia: Luăm lista de monitoare și aplicăm wallpaper-ul pe fiecare
# Folosim hyprctl pentru a lua numele monitoarelor
monitors=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

for m in $monitors; do
    echo "Setare wallpaper pe monitorul: $m"
    hyprctl hyprpaper wallpaper "$m,$WALL"
done

# Opțional: notificare
# notify-send "Wallpaper setat pe toate monitoarele"
