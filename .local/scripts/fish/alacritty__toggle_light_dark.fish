#!/usr/bin/fish
set CONFIG_PATH ~/.config/alacritty/alacritty.toml

# change light and dark themes
set light "ayu_light"
set dark "ayu_dark"

set THEMES_PATH ~/.config/alacritty/themes/themes/
set light_theme "$THEMES_PATH$light.toml"
set dark_theme "$THEMES_PATH$dark.toml"

function toggle_light_dark
    set current_theme (awk -F'"' '/import = \[/{print $2}' $CONFIG_PATH)
    printf $current_theme
    switch $current_theme
        case $light_theme # '*light'
            set new_theme $dark_theme
        case $dark_theme # '*dark'
            set new_theme $light_theme
        case '*'
            set new_theme $dark_theme
    end

    awk -v newtheme="$new_theme" '{sub(/import = \[.*\]/, "import = [\"" newtheme "\"]"); print}' $CONFIG_PATH > $CONFIG_PATH".tmp" && mv $CONFIG_PATH".tmp" $CONFIG_PATH
end

toggle_light_dark
