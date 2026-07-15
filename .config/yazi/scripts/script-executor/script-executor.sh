#!/usr/bin/env bash
set -Eeuo pipefail

# ──── Configuration ─────────────────────────────────────────────────
readonly SCRIPT_DIR="$HOME/.config/yazi/scripts"

source "${SCRIPT_DIR}/lib/costants.sh"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/validation.sh"
source "${SCRIPT_DIR}/lib/executor.sh"

# ──── Main Function ─────────────────────────────────────────────────
main() {
    local target_file="$1"
    validate::arguments "$@"
    validate::file "$target_file"
    executor::execute_file "$target_file"
}

main "$@"
