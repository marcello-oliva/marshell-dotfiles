#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGUMENT=2
readonly EXIT_FILE_NOT_FOUND=3
readonly EXIT_UNSUPPORTED_TYPE=4
readonly EXIT_EXECUTION_FAILED=5

readonly -a EXECUTOR_INTERPRETERS=(
    bash
    sh
    zsh
    dash
    fish
    ksh
    "python[0-9.]*"
    "lua[0-9.]*"
    perl
    ruby
    node
)

log_info() {
    printf '[INFO] %s\n' "$*"
}

log_error() {
    printf '[ERROR] %s\n' "$*" >&2
}

validate_arguments() {
    if [[ $# -ne 1 ]]; then
        log_error "Usage: ${SCRIPT_NAME} <file>"
        exit "$EXIT_INVALID_ARGUMENT"
    fi
}

validate_file() {
    local target_file="$1"

    if [[ ! -f "$target_file" ]]; then
        log_error "File not found: $target_file"
        exit "$EXIT_FILE_NOT_FOUND"
    fi
}

# Built once at startup by joining EXECUTOR_INTERPRETERS with "|".
# Matches BOTH:
#   #!/bin/bash                    (direct interpreter path)
#   #!/usr/bin/env bash            (env lookup)
#   #!/usr/bin/env -S python3 -u   (env lookup with -S and extra args)
build_shebang_pattern() {
    local joined
    joined="$(IFS='|'; echo "${EXECUTOR_INTERPRETERS[*]}")"
    echo "^#![[:space:]]*(/[^[:space:]]*/(${joined})|/usr/bin/env[[:space:]]+(-S[[:space:]]+)?(${joined}))([[:space:]]|\$)"
}

readonly SHEBANG_PATTERN="$(build_shebang_pattern)"

read_shebang() {
    local target_file="$1"
    head -n1 -- "$target_file" 2>/dev/null
}

is_shell_script() {
    local target_file="$1"
    local shebang
    shebang="$(read_shebang "$target_file")"
    [[ "$shebang" =~ $SHEBANG_PATTERN ]]
}

grant_permission_if_needed() {
    local target_file="$1"

    if [[ -x "$target_file" ]]; then
        echo "false"
        return 0
    fi

    log_info "Adding executable permission: $target_file"
    chmod +x "$target_file"
    echo "true"
}

revert_permission() {
    local target_file="$1"
    log_info "Reverting executable permission (execution failed): $target_file"
    chmod -x "$target_file" || log_error "Could not revert permission on: $target_file"
}

run_script() {
    local target_file="$1"
    local shebang
    shebang="$(read_shebang "$target_file")"

    log_info "Executing script (shebang: ${shebang}): $target_file"
    "$target_file"
}

execute_file() {
    local target_file="$1"

    if ! is_shell_script "$target_file"; then
        log_error "Unsupported file type: $target_file"
        exit "$EXIT_UNSUPPORTED_TYPE"
    fi

    local granted_permission
    granted_permission="$(grant_permission_if_needed "$target_file")"

    if run_script "$target_file"; then
        return 0
    fi

    log_error "Execution failed: $target_file"

    if [[ "$granted_permission" == "true" ]]; then
        revert_permission "$target_file"
    fi

    exit "$EXIT_EXECUTION_FAILED"
}

main() {
    local target_file="$1"
    validate_arguments "$@"
    validate_file "$target_file"
    execute_file "$target_file"
}

main "$@"
