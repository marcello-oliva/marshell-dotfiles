#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_EDITOR_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_EDITOR_SH=1

editor::open_file() {
    local target_file="$1"

    if [[ -w "$target_file" ]]; then
        exec "$EDITOR" "$target_file"
    else
        privileged::edit_as_root "$target_file"
    fi
}
