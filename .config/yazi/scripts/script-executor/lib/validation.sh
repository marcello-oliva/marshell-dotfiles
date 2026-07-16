#!/usr/bin/env bash

if [[ -n "${_YAZI_LIB_VALIDATION_SH:-}" ]]; then return 0; fi
readonly _YAZI_LIB_VALIDATION_SH=1

validate::arguments() {
    if [[ $# -ne 1 ]]; then
        logger::error "Usage: ${SCRIPT_NAME} <file>"
        exit "$EXIT_INVALID_ARGUMENT"
    fi
}

validate::file() {
    local target_file="$1"

    if [[ ! -f "$target_file" ]]; then
        logger::error "File not found: $target_file"
        exit "$EXIT_FILE_NOT_FOUND"
    fi
}
