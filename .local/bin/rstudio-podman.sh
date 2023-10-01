#!/bin/sh

# Check if an argument was provided
if [ "$#" -eq 1 ]
then
  # If an argument was provided, we want interactive
  podman run  -it localhost/rstudio /bin/bash
fi


bwrap \
    --bind /var/chroots/fedora/  / \
    --bind /tmp /tmp \
    --bind /usr/share/fonts /usr/share/fonts \
    --bind $HOME $HOME \
    --bind-try /proc /proc \
    --bind-try /sys /sys \
    --bind-try /run /run \
    --dev-bind /dev /dev \
    --dev-bind /dev/shm /dev/shm \
    --setenv DISPLAY :0 \
    --unshare-all \
    --share-net \
    --hostname sandbox \
    --setenv DISPLAY $DISPLAY \
    rstudio --no-sandbox
    # code --no-sandbox
     # "${1}" ||
     echo "Error! did you run \`xhost +\`?"

## podman run -dt --rm \
##     -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
##     --userns keep-id \
##     -v /run:/run \
##     -v /etc/localtime:/etc/localtime:ro \
##     -v /usr/share/fonts:/usr/share/fonts:ro \
##     -v /home/ryan:/home/ryan \
##     -v /proc:/proc \
##     -v /dev/shm:/dev/shm \
##     -v /tmp:/tmp \
##     --security-opt label=type:container_runtime_t \
##     -e "DISPLAY"  rstudio
