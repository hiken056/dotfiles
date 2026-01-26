#!/bin/bash

# Numele monitoarelor tale
INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

# Meniul
OP_LAPTOP="1. 💻 Laptop Only"
OP_EXTERN="2. 📺 External Only"
OP_MIRROR="3. ♻️  Mirror"
OP_EXTEND="4. ➡️  Extend"

CHOICE=$(echo -e "$OP_LAPTOP\n$OP_EXTERN\n$OP_MIRROR\n$OP_EXTEND" | rofi -dmenu -i -p "Monitor Config" -width 30 -lines 4)

if [[ "$CHOICE" == *"Laptop"* ]]; then
    hyprctl keyword monitor "$EXTERNAL,disable"
    hyprctl keyword monitor "$INTERNAL,preferred,auto,1"

elif [[ "$CHOICE" == *"External"* ]]; then
    hyprctl keyword monitor "$INTERNAL,disable"
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"

elif [[ "$CHOICE" == *"Mirror"* ]]; then
    hyprctl keyword monitor "$INTERNAL,preferred,auto,1"
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$INTERNAL"

elif [[ "$CHOICE" == *"Extend"* ]]; then
    hyprctl keyword monitor "$INTERNAL,preferred,0x0,1"
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
fi
