#!/bin/bash
# https://github.com/hyprwm/Hyprland/discussions/830

switch_based_on_class() {
    WINDOW=$(hyprctl clients | grep "class: " | awk '{gsub("class: ", "");print}' | wofi --show dmenu)
    if [ "$WINDOW" = "" ]; then
        exit
    fi
    hyprctl dispatch focuswindow $WINDOW
}



regex='^Window\s\([a-z0-9]*\)\s->\s\([^:]*\):'
# Choose the title
title=$(hyprctl clients | grep ${regex} | sed -e "s#${regex}#\1  -- \2\n#" | sort -u | wofi -i --show dmenu)
address=0x$(echo $title | cut -d ' ' -f 1)
hyprctl dispatch focuswindow address:${address}
# hyprctl clients | grep ${regex} | sed -e "s#${regex}#\1\2\n#"
