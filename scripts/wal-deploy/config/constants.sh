#!/usr/bin/env bash

[[ -n "${WAL_DEPLOY_CONFIG_LOADED:-}" ]] && return 0
readonly WAL_DEPLOY_CONFIG_LOADED=1

# Display name of each application (used in log output and CLI lookups).
readonly -a WAL_DEPLOY_APP_NAMES=(
    "dgop"
    "spicetify"
)

# pywal-generated cache file
readonly -a WAL_DEPLOY_CACHE_FILES=(
    "$HOME/.cache/wal/colors-dgop.json"
    "$HOME/.cache/wal/colors-spicetify.ini"
)

# Destination symlink path
readonly -a WAL_DEPLOY_TARGET_LINKS=(
    "$HOME/.config/dgop/colors.json"
    "$HOME/.config/spicetify/Themes/pywal/color.ini"
)
