#!/usr/bin/python3

from subprocess import run


def main():
    p = get_packages()
    run(["rpm-ostree", "install", *p], check=True)


def get_packages() -> list[str]:
    packages = []

    # So vim can be used outside a distrobox
    packages += ["ctags", "nodejs", "nodejs-npm", "wl-clipboard", "xclip"]

    # So the terminal is a bit friendlier
    # Zoxide could be installed through cargo, having it on hand might be nice though
    packages += ["ranger", "tmux", "fish", "zoxide"]

    # Include sway so I can run it instead of Gnome
    # Window Manager
    packages += [
        "sway",
        "swaybg",
        "swayidle",
        "swaylock",
        "grim",
        "grimshot",
        "slurp",
        "waybar",
        "wev",
    ]

    # Gnome extensions would be nice if automatically packaged
    packages += [
        "gnome-shell-extension-pop-shell",
        "gnome-shell-extension-dash-to-dock",
        "gnome-shell-extension-dash-to-panel",
    ]

    return packages


if __name__ == "__main__":
    main()
