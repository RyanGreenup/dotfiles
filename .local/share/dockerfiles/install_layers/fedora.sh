#!/bin/sh

# Fedora
rpm-ostree --help &&\
	rpm-ostree install  \
		ctags nodejs nodejs-npm wl-clipboard xclip \
		ranger tmux fish zoxide \
		sway  swaybg swayidle swaylock grim grimshot slurp waybar wev \
		gnome-shell-extension-pop-shell \
		gnome-shell-extension-dash-to-dock \
		gnome-shell-extension-dash-to-panel



