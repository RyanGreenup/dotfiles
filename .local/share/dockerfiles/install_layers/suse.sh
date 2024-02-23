#!/bin/sh


sudo transactional-update -i pkg install openSUSE-repos-NVIDIA

# Go6 is maxwell and transactional-up
# Must not use --no-confirm, licence must be accepted
sudo transactional-update --continue pkg install  nvidia-driver-G06-kmp-default nvidia-video-G06 nvidia-gl-G06 nvidia-compute-G06

# These were not listed by the docs but are required for nvidia-smi and nvcc respectively
sudo transactional-update --continue pkg install \
    nvidia-compute-utils-G06


# Suse
# sway swaybg swayidle swaylock grim slurp waybar wev \
sudo transactional-update --continue pkg install --no-confirm \
	neovim ctags nodejs-default npm-default wl-clipboard xclip \
	ripgrep fd ranger tmux fish zoxide fzf \
	gnome-shell-extension-pop-shell guake \
	i3-gaps i3-gaps-devel i3status i3blocks i3lock maim arandr \
	steam-devices \
    neofetch \
    docker docker-compose podman-compose \
    fuse-devel fuse libfuse2


flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install org.freedesktop.Platform.ffmpeg-full
flatpak install com.valvesoftware.Steam

