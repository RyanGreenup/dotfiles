#!/bin/sh
killall polybar
leftwm-theme list | rg '^[\s]*[a-zA-Z]*/([a-zA-Z0-9 ]+):.*' -r '$1' | dmenu -i | xargs -d '\n' leftwm-theme apply
