#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_PRIVILEGED_EDITOR_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_PRIVILEGED_EDITOR_SH=1

privileged::edit_as_root() {
    local orig="$1"

    if [[ -L "$orig" ]]; then
        logger::error "Refusing symlink target: $orig"
        exit "$EXIT_PRIVILEGED_EDIT_FAILED"
    fi

    local tmp
    tmp="$(mktemp)"

    cp --preserve=mode,timestamps "$orig" "$tmp"

    "$EDITOR" --wait "$tmp"

    if ! pkexec install -m 644 "$tmp" "$orig"; then
        logger::error "Privileged write-back failed: $orig"
        rm -f "$tmp"
        exit "$EXIT_PRIVILEGED_EDIT_FAILED"
    fi

    rm -f "$tmp"
}
