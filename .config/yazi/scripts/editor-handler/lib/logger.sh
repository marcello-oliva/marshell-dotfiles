#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_LOGGER_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_LOGGER_SH=1

logger::info() {
    printf '[INFO] %s\n' "$*"
}

logger::error() {
    printf '[ERROR] %s\n' "$*" >&2
}
