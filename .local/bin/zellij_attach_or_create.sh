#!/usr/bin/env bash

# Adapted from <https://zellij.dev/documentation/integration.html>

if [ "$#" -ge 1 ]; then
    zellij attach "${1}" || zellij --session "${1}"
    exit 0
fi


ZJ_SESSIONS=$(zellij list-sessions)
NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)

if [ "${NO_SESSIONS}" -ge 2 ]; then
    zellij attach \
    "$(echo "${ZJ_SESSIONS}" | sk)"
else
   zellij attach -c
fi
