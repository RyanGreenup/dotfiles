# update nix
nix-channel --update
nix-env --upgrade
nix-env -if default.nix
# Update Emerge
doas emerge --update --deep --newuse @world
