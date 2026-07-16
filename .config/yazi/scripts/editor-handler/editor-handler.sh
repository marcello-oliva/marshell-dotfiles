#!/usr/bin/env bash
set -Eeuo pipefail

# ──── Configuration ─────────────────────────────────────────────────
readonly SCRIPT_DIR="$HOME/.config/yazi/scripts/editor-handler"

source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/terminal.sh"
source "${SCRIPT_DIR}/lib/privileged-editor.sh"
source "${SCRIPT_DIR}/lib/editor.sh"

# ──── Main Function ─────────────────────────────────────────────────
main() {
    validate::arguments "$@"
    local target="$1"
    validate::target "$target"

    if [[ -d "$target" ]]; then
        terminal::open_directory "$target"
    elif [[ -f "$target" ]]; then
        editor::open_file "$target"
    else
        logger::error "Invalid target: $target"
        exit "$EXIT_TARGET_NOT_FOUND"
    fi
}

main "$@"
