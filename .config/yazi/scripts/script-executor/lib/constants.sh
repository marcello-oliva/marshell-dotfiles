#!/usr/bin/env bash

if [[ -n "${_YAZI_LIB_COSTANTS_SH:-}" ]]; then return 0; fi
readonly _YAZI_LIB_COSTANTS_SH=1

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
    fish
    "python[0-9.]*"
    "lua[0-9.]*"
    ruby
    node
)
