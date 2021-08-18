#!/bin/bash

# Change Directory
dir="$HOME/.local/radicale"

if [[ -d "${dir}" ]]
then
	cd "${dir}"
else
	mkdir "${dir}"
	cd "${dir}"
fi


radicale -H 0.0.0.0:5232                                      \
    --storage-type multifilesystem                            \
    --storage-filesystem-folder ./data    \
    --auth-type htpasswd                                      \
    --auth-htpasswd-filename ./radicale_password.passwd       \
    --ssl                                                     \
        --certificate /etc/ssl/private/vidar.cer                 \
        --key         /etc/ssl/private/vidar.key                "${@}"

