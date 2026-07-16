#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_TERMINAL_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_TERMINAL_SH=1

terminal::has_active_session() {
    "$TERMINAL" @ ls >/dev/null 2>&1
}

terminal::open_directory() {
    local target_dir="$1"

    if terminal::has_active_session; then
        "$TERMINAL" @ launch --type=tab --cwd="$target_dir" -- "$SHELL"
    else
        "$TERMINAL" --detach --directory "$target_dir"
    fi
}
