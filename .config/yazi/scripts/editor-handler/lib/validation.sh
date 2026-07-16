#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_VALIDATION_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_VALIDATION_SH=1

validate::arguments() {
    if [[ $# -ne 1 || -z "${1:-}" ]]; then
        logger::error "Usage: ${SCRIPT_NAME} <path>"
        exit "$EXIT_INVALID_ARGUMENT"
    fi
}

validate::target() {
    local target="$1"
    if [[ ! -e "$target" ]]; then
        logger::error "Invalid target: $target"
        exit "$EXIT_TARGET_NOT_FOUND"
    fi
}
