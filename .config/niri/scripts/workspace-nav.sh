#!/bin/sh
# Navigate to the next or previous workspace on the current output.
# Creates a new numbered workspace if none exists in that direction.
#
# Usage: workspace-nav.sh next|prev
#
# Relies on:
#   swaymsg -t get_workspaces   (swaymsg.1, sway-ipc.7)
#   workspace number <N>        (sway.5)

dir="$1"

# Capture workspace list once
ws_json=$(swaymsg -t get_workspaces)

current=$(echo "$ws_json" | jq -r '.[] | select(.focused) | .num')
output=$(echo  "$ws_json" | jq -r '.[] | select(.focused) | .output')

# Sorted workspace numbers on this output
nums=$(echo "$ws_json" | jq -r --arg out "$output" \
    '[.[] | select(.output == $out) | .num] | sort[]')

case "$dir" in
    next)
        target=$(echo "$nums" | awk -v c="$current" '$1 > c { print; exit }')
        [ -z "$target" ] && target=$((current + 1))
        ;;
    prev)
        target=$(echo "$nums" | awk -v c="$current" '$1 < c { print }' | tail -1)
        [ -z "$target" ] && target=$((current - 1))
        [ "$target" -lt 1 ] && target=1
        ;;
    *)
        echo "Usage: workspace-nav.sh next|prev" >&2
        exit 1
        ;;
esac

swaymsg "workspace number $target"
