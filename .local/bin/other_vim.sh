#!/bin/sh

NVIM_PROFILE_NAME="doom-nvim"
NVIM_INIT_FILE="init.lua"
NVIM_COMMAND="nvim"

exec env XDG_CONFIG_HOME="$HOME/.config/nvim-profiles/${NVIM_PROFILE_NAME}" \
         XDG_DATA_HOME="$HOME/.local/share/nvim-profiles/${NVIM_PROFILE_NAME}" \
         XDG_CACHE_HOME="$HOME/.cache/nvim-profiles/${NVIM_PROFILE_NAME}" \
         ${NVIM_COMMAND} -u "$HOME/.config/nvim-profiles/${NVIM_PROFILE_NAME}/nvim/${NVIM_INIT_FILE}"\
         "$@"
