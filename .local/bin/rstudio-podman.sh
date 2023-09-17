#!/bin/sh

# Check if an argument was provided
if [ "$#" -eq 1 ]
then
  # If an argument was provided, we want interactive
  podman run  -it localhost/rstudio /bin/bash
fi

podman run -dt --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --userns keep-id \
    -v /run:/run \
    -v /etc/localtime:/etc/localtime:ro \
    -v /usr/share/fonts:/usr/share/fonts:ro \
    -v /sys:/sys \
    -v /home/ryan:/home/ryan \
    -v /proc:/proc \
    -v /dev/shm:/dev/shm \
    -v /tmp:/tmp \
    --security-opt label=type:container_runtime_t \
    -e "DISPLAY"  rstudio
