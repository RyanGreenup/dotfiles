#!/bin/sh
set -euf

t=firefox
i=localhost/${t}
d=containerized_apps
n=${d}-${t}

podman build -t ${t} .

p=webapp
distrobox create \
    -i localhost/firefox-${p} \
    -H /home/ryan/.local/share/containerized_apps/firefox-${p} \
    --volume $HOME/Downloads:$HOME/Downloads \
    -n containerized_apps-firefox-${p}

# TODO firefox should be more sandboxed, use podman directly
#      For example the following command will kill ALL firefoxes
#          distrobox enter containerized_apps-firefox-webapp -- pkill firefox
#      Two can be started from each profile, but they clearly see each other
#      which necessitates the use of the --new-instance flag, however, this
#      flag can only used on the first run in that container, the second
#      will fail, so starting firefox pretty much has to be done manually with
#      the mindfullness to use the --new-instance flag when needed.
#      Set this up in podman to isolate it more.
#      All of these also seem to share the same history
#
# NOTE must start with the --new-instance flag, it detects other firefox
#      instances somehow, modify the exported applications
p=arkenfox
distrobox create \
    -i localhost/firefox-${p} \
    -H /home/ryan/.local/share/containerized_apps/firefox-${p} \
    --volume $HOME/Downloads:$HOME/Downloads \
    --unshare-all \
    -n containerized_apps-firefox-${p}
