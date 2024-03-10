#!/bin/sh
set -euf

# Set variables
s_dir="/tmp/screenshots"
f_name="${s_dir}/$(date +%Y-%m-%d_%H-%m-%s).png"
mkdir -p "${s_dir}"

# Check for dependencies
for cmd in slurp grim wl-copy; do
    if ! command -v $cmd > /dev/null; then
        echo "$cmd not found"
        exit 1
    fi
done

# Take Screenshot
grim -t png -g "$(slurp)" "${f_name}"
# Copy to clipboard
wl-copy -t image/png < $f_name
