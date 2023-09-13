#!/bin/sh


main() {

    # Check number of arguments
    if [ "$#" -eq 0 ]; then
        echo "Error: No arguments provided."
        usage
    fi

    nvidia
    user_dir
    keyring
    notifications

    # Run Wayland Session
    exec dbus-run-session "$@"
}

# help function
usage() {
    echo "Usage: $0 <arg1> <arg2> ... <argN>"
    echo "Your meaningful description goes here."
    exit 1
}

nvidia() {
    # Fix cursors
    export WLR_NO_HARDWARE_CURSORS=1

    # Fix other shit
    # https://www.reddit.com/r/wayland/comments/13g1b7b/wayland_intel_nvidia/jk1nlcj/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    ## export VGL_GLLIB=/usr/lib64/nvidia/libGL.so.1
    ## export __NV_PRIME_RENDER_OFFLOAD=1
    ## export __VK_LAYER_NV_optimus=NVIDIA_only
    ## export __GLX_VENDOR_LIBRARY_NAME=nvidia


    # These seem to slow down sway and Hikari, unsure about Hyprland
    # More fix other shit
    # http://wiki.hyprland.org/Configuring/Environment-variables/#nvidia-specific
    # export LIBVA_DRIVER_NAME=nvidia
    # export GBM_BACKEND=nvidia-drm
    # export __GLX_VENDOR_LIBRARY_NAME=nvidia
    # export __GL_GSYNC_ALLOWED=1
    # export __GL_VRR_ALLOWED=0
    export WLR_DRM_NO_ATOMIC=1
}

user_dir() {
    # Set up XDG_USERS_DIR (assuming no elogind [i.e. using seat])
    uid=$(id -u)
    export XDG_USERS_DIR=/tmp/"${uid}"
    mkdir "$XDG_USERS_DIR"
    chmod 0700 "$XDG_USERS_DIR"
}


wallpaper() {
    # set a wallpaper
    swaybg -m tile -o '*' -i /home/ryan/Pictures/wallpapers/mind_swirles.png &
}

keyring() {
    # Keyring
    gnome-keyring-daemon -d

    # Unlock the keyring
    # TODO
    "$HOME"/.local/bin/unlock_keyring.sh
}

notifications() {
    # Notification Daemon
    mako &
}


main "@"


