#!/bin/sh
set -euf

t=thunderbird
i=localhost/${t}
d=containerized_apps
n=${d}-${t}

podman build --layers -t ${t} . && \
    distrobox create -i ${i} -n ${n} -H ~/.local/share/${d}/${t}
