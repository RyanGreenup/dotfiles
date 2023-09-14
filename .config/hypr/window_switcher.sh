#!/bin/sh


NOTHING_DO_MESSAGE="Nothing do."

format=$(printf "\"\(.address) | \(.title) >> \(.class)\"")
windows="$(hyprctl clients -j | jq -r ".[] | $format")"
# window=$(echo "$windows" | rofi -dmenu -matching normal -i)
window=$(echo "$windows" | wofi -dmenu -matching normal -i)
if [ "$window" = "" ]; then
	echo "$NOTHING_DO_MESSAGE"
	exit 0
fi

address=$(echo "${window}" | cut -d "|" -f 1)
echo "${address}"
if [ "$address" = "" ]; then
	echo "$NOTHING_DO_MESSAGE"
	exit 0
else
	hyprctl dispatch focuswindow address:"${address}"
fi



# This script is adapted from
# https://github.com/irdaislakhuafa/hyprland_window_switcher/blob/master/hyprland_window_switcher.sh
# See Also
# * /home/ryan/.local/bin/sway_window_switch.sh
# ** https://gist.github.com/lbonn/89d064cde963cfbacabd77e0d3801398

