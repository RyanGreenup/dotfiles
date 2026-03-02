#!/bin/sh
# Toggle a named scratchpad window.
#
# If a window with the given mark exists, toggle its visibility.
# If no such window exists, launch the command — the for_window
# rule in scratchpads.conf will auto-mark and move it to scratchpad.
#
# Usage: scratchpad-toggle.sh <mark> <command...>
#
# Relies on:
#   swaymsg -t get_marks   (swaymsg.1)
#   [con_mark=] criteria   (sway.5 CRITERIA)
#   scratchpad show        (sway.5)

MARK="$1"
shift

if swaymsg -t get_marks | jq -e "index(\"$MARK\")" > /dev/null 2>&1; then
    swaymsg "[con_mark=\"$MARK\"] scratchpad show"
else
    exec "$@" &
fi
