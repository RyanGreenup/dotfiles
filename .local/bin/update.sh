# update nix
doas nix-channel --update
doas nix-env --upgrade
doas nix-env -if default.nix
# Update Emerge
doas emerge --update --deep --newuse @world
