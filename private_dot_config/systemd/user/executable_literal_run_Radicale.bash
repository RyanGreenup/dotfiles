#!/bin/bash

# Change Directory
dir="$HOME/.local/radicale/"
pass_file="radicale_password.passwd"

if [[ -d "${dir}" ]]
then
	cd "${dir}"
else
	mkdir "${dir}"
	cd "${dir}"
fi

if [[ ! -f "${pass_file}" ]]
then
	echo "No Password File Found, looking for ${dir}${pass_file}"
	echo "Fix this by running:"
	echo "htpasswd -c ${dir}${pass_file} [username]"
	exit 1
fi




radicale -H 0.0.0.0:5232                                      \
    --storage-type multifilesystem                            \
    --storage-filesystem-folder ./data    \
    --auth-type htpasswd                                      \
    --auth-htpasswd-filename ./radicale_password.passwd       \
    --ssl                                                     \
        --certificate /etc/ssl/private/vidar.cer                 \
        --key         /etc/ssl/private/vidar.key                "${@}"

