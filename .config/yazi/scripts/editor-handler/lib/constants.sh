#!/usr/bin/env bash

if [[ -n "${_EDITOR_SETUP_LIB_CONSTANTS_SH:-}" ]]; then return 0; fi
readonly _EDITOR_SETUP_LIB_CONSTANTS_SH=1

readonly SCRIPT_NAME="$(basename "$0")"

readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGUMENT=2
readonly EXIT_TARGET_NOT_FOUND=3
readonly EXIT_PRIVILEGED_EDIT_FAILED=4

readonly TERMINAL="kitty"
readonly EDITOR="zeditor"
