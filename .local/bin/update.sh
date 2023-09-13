# update nix
nix-channel --update
nix-env --upgrade
nix-env -if /home/ryan/.config/nixpkgs/default.nix
nix-store --gc
nix-store --optimise
# Update Emerge
doas emaint --auto sync
doas emerge --update --deep --newuse @world
