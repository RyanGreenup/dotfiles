#!/bin/sh


main() {

    # Check number of arguments
    if [ "$#" -eq 0 ]; then
        echo "Error: No arguments provided."
        usage
    fi

    nvidia
    user_dir
    # keyring
    notifications

    # Run Wayland Session
    exec dbus-run-session "$@"
}

# help function
usage() {
    echo "Usage: $0 [Hyprland | hikari | sway]"
    echo "Start a wayland server with all the env vars set and dbus running"
    exit 1
}

nvidia() {
    #[fn_nvida]

    #[fn_nvidia_reddit]
    # Fix cursors
    export WLR_NO_HARDWARE_CURSORS=1

    # More from [fn_nvidia_reddit]
    ## export VGL_GLLIB=/usr/lib64/nvidia/libGL.so.1
    ## export __NV_PRIME_RENDER_OFFLOAD=1
    ## export __VK_LAYER_NV_optimus=NVIDIA_only
    ## export __GLX_VENDOR_LIBRARY_NAME=nvidia


    #[fn_nvidia_hyprland]
    # export LIBVA_DRIVER_NAME=nvidia
    # export GBM_BACKEND=nvidia-drm
    # export __GLX_VENDOR_LIBRARY_NAME=nvidia
    # export __GL_GSYNC_ALLOWED=1
    # export __GL_VRR_ALLOWED=0
    export WLR_DRM_NO_ATOMIC=1
}

user_dir() {
    #[fn_usage]

    if test -z "${XDG_RUNTIME_DIR}"; then
      uid="$(id -u)"
      export XDG_RUNTIME_DIR=/tmp/"${uid}"-runtime-dir
        if ! test -d "${XDG_RUNTIME_DIR}"; then
            mkdir "${XDG_RUNTIME_DIR}"
            chmod 0700 "${XDG_RUNTIME_DIR}"
        fi
    fi
}


wallpaper() {
    # set a wallpaper
    swaybg -m tile -o '*' -i /home/ryan/Pictures/wallpapers/mind_swirles.png &
}

keyring() {
    # Keyring
    gnome-keyring-daemon -d

    # Unlock the keyring
    if [ -f "$HOME/.local/bin/unlock_keyring.sh" ]; then
        "$HOME"/.local/bin/unlock_keyring.sh
    else
        echo "Error: unlock_keyring.sh does not exist"
        exit 1
    fi
}

notifications() {
    # Notification Daemon
    mako &
}


main "${@}"

#[fn_usage]
    # Set up XDG_USERS_DIR (assuming no elogind [i.e. using seat])
    # This isn't needed if on SystemD
    # Don't put this on zfs (https://docs.freebsd.org/en/books/handbook/wayland/)
    # Adapted from https://wiki.gentoo.org/wiki/Sway

#[fn_nvidia]
    # Toggle these arbitrarily :shrug:
#[fn_nvidia_reddit]
    # https://www.reddit.com/r/wayland/comments/13g1b7b/wayland_intel_nvidia/jk1nlcj/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
#[fn_nvidia_hyprland]
    # These seem to slow down sway and Hikari, unsure about Hyprland
    # More fix other shit
    # http://wiki.hyprland.org/Configuring/Environment-variables/#nvidia-specific
