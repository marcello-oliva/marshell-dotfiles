#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

TERMINAL="kitty"
EDITOR="zeditor"
ROOT_EDITOR="$HOME/.local/bin/polkit-root-edit"

open_dir() {
    if "$TERMINAL" @ ls >/dev/null 2>&1; then
        "$TERMINAL" @ launch --type=tab --cwd="$TARGET" -- "$SHELL"
    else
        "$TERMINAL" --detach --directory "$TARGET"
    fi
}

open_file() {
    if [[ -w "$TARGET" ]]; then
        exec "$EDITOR" "$TARGET"
    else
        exec "$ROOT_EDITOR" "$TARGET"
    fi
}

if [[ -d "$TARGET" ]]; then
    open_dir
elif [[ -f "$TARGET" ]]; then
    open_file
else
    echo "invalid target"
    exit 1
fi
