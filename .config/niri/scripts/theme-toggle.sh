#!/bin/sh
# Toggle between light and dark GTK theme.

current=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$current" = "'prefer-dark'" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
else
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi
