# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

# Produces "21 days", for example
uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)

# The abbreviated weekday (e.g., "Sat"), followed by the ISO-formatted date
# like 2018-10-06 and the time (e.g., 14:01)
date_formatted=$(date "+%a %F %H:%M")

# Get the Linux version but remove the "-1-ARCH" part
linux_version=$(uname -r | cut -d '-' -f1)

# Returns the battery status: "Full", "Discharging", or "Charging".
battery_status=$(cat /sys/class/power_supply/BAT?/status)
battery_rate=$(cat /sys/class/power_supply/BAT?/capacity)

if [[ $battery_status == "Discharging" ]]; then
    battery_rate = "C $battery_rate"

fi

# TODO an if test for battery
# Emojis and characters for the status bar
echo [↑ $uptime_formatted ]  [🐧 $linux_version ] [⚡  $battery_rate %] [$date_formatted]

