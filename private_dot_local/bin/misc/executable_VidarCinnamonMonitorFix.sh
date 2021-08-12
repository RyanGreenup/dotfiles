#!/usr/bin/env bash
set -euo pipefail

##############################
#### Start Xrandr ############
##############################
## /usr/lib/x86_64-linux-gnu/cinnamon-settings-daemon/csd-xrandr


##############################
#### Restart Cinnamon ########
##############################
cinnamon --replace

##############################
#### Scale the Right Monitor #
##############################
xrandr --output DP-2 --dpi 144 --output HDMI-0 --auto --scale 2x2 --right-of DP-2

##############################
##### Scale the Left Monitor to zoom out
##############################
xrandr --output DP-2 --scale 1.25x1.25
