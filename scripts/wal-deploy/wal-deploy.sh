#!/usr/bin/env bash
set -euo pipefail

# ──── Configuration ────────────────────────────────────────────────────────
readonly -a WAL_DEPLOY_APP_NAMES=(
    "dgop"
)

readonly -a WAL_DEPLOY_CACHE_FILES=(
    "$HOME/.cache/wal/colors-dgop.json"
)

readonly -a WAL_DEPLOY_TARGET_LINKS=(
    "$HOME/.config/dgop/colors.json"
)

# ──── Functions ────────────────────────────────────────────────────────
link_application() {
    local app_name="$1"
    local cache_file="$2"
    local target_link="$3"
    local target_dir
    target_dir="$(dirname -- "$target_link")"

    mkdir -p -- "$target_dir"

    if [[ ! -f "$cache_file" ]]; then
        echo "[WARN] (${app_name}) ${cache_file} not found — run 'wal' at least once first" >&2
    fi

    ln -sf -- "$cache_file" "$target_link"
    echo "[OK] ${app_name}: ${target_link} -> ${cache_file}"
}

link_all_programs() {
    local count="${#WAL_DEPLOY_APP_NAMES[@]}"

    if [[ "${#WAL_DEPLOY_CACHE_FILES[@]}" -ne "$count" || "${#WAL_DEPLOY_TARGET_LINKS[@]}" -ne "$count" ]]; then
        echo "[ERR] WAL_DEPLOY_APP_NAMES, WAL_DEPLOY_CACHE_FILES and WAL_DEPLOY_TARGET_LINKS must be the same length" >&2
        return 1
    fi

    local i
    for (( i = 0; i < count; i++ )); do
        link_application \
            "${WAL_DEPLOY_APP_NAMES[i]}" \
            "${WAL_DEPLOY_CACHE_FILES[i]}" \
            "${WAL_DEPLOY_TARGET_LINKS[i]}"
    done
}

link_user_program() {
    local wanted="$1"
    local count="${#WAL_DEPLOY_APP_NAMES[@]}"
    local i

    for (( i = 0; i < count; i++ )); do
        if [[ "${WAL_DEPLOY_APP_NAMES[i]}" == "$wanted" ]]; then
            link_application \
                "${WAL_DEPLOY_APP_NAMES[i]}" \
                "${WAL_DEPLOY_CACHE_FILES[i]}" \
                "${WAL_DEPLOY_TARGET_LINKS[i]}"
            return 0
        fi
    done

    echo "[ERR] Application '${wanted}' not found in WAL_DEPLOY_APP_NAMES" >&2
    return 1
}


# ──── Entrypoint ────────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -ge 1 ]]; then
        link_user_program "$1"
    else
        link_all_programs
    fi
fi
