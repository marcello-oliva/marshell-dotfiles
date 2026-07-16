#!/usr/bin/env bash

if [[ -n "${_YAZI_LIB_EXECUTOR_SH:-}" ]]; then return 0; fi
readonly _YAZI_LIB_EXECUTOR_SH=1

executor::_build_shebang_pattern() {
    local joined
    joined="$(IFS='|'; echo "${EXECUTOR_INTERPRETERS[*]}")"
    echo "^#![[:space:]]*(/[^[:space:]]*/(${joined})|/usr/bin/env[[:space:]]+(-S[[:space:]]+)?(${joined}))([[:space:]]|\$)"
}

readonly EXECUTOR_SHEBANG_PATTERN="$(executor::_build_shebang_pattern)"

executor::read_shebang() {
    local target_file="$1"
    head -n1 -- "$target_file" 2>/dev/null
}

executor::is_shell_script() {
    local target_file="$1"
    local shebang
    shebang="$(executor::read_shebang "$target_file")"
    [[ "$shebang" =~ $EXECUTOR_SHEBANG_PATTERN ]]
}

executor::grant_permission_if_needed() {
    local target_file="$1"

    if [[ -x "$target_file" ]]; then
        echo "false"
        return 0
    fi

    logger::info "Adding executable permission: $target_file"
    chmod +x "$target_file"
    echo "true"
}

executor::revert_permission() {
    local target_file="$1"
    logger::info "Reverting executable permission (execution failed): $target_file"
    chmod -x "$target_file" || logger::error "Could not revert permission on: $target_file"
}

executor::run() {
    local target_file="$1"
    local shebang
    shebang="$(executor::read_shebang "$target_file")"

    logger::info "Executing script (shebang: ${shebang}): $target_file"
    "$target_file"
}

executor::execute_file() {
    local target_file="$1"

    if ! executor::is_shell_script "$target_file"; then
        logger::error "Unsupported file type: $target_file"
        exit "$EXIT_UNSUPPORTED_TYPE"
    fi

    local granted_permission
    granted_permission="$(executor::grant_permission_if_needed "$target_file")"

    if executor::run "$target_file"; then
        return 0
    fi

    logger::error "Execution failed: $target_file"

    if [[ "$granted_permission" == "true" ]]; then
        executor::revert_permission "$target_file"
    fi

    exit "$EXIT_EXECUTION_FAILED"
}
