#!/usr/bin/env bash

[[ -n "${WAL_DEPLOY_FUNCTIONS_LOADED:-}" ]] && return 0
readonly WAL_DEPLOY_FUNCTIONS_LOADED=1

if [[ -z "${WAL_DEPLOY_CONFIG_LOADED:-}" ]]; then
    echo "[ERR] wal-deploy.functions.sh requires wal-deploy.config.sh — check sourcing order" >&2
    return 1 2>/dev/null || exit 1
fi

wal_deploy::link_one() {
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

wal_deploy::link_all() {
    local count="${#WAL_DEPLOY_APP_NAMES[@]}"

    if [[ "${#WAL_DEPLOY_CACHE_FILES[@]}" -ne "$count" || "${#WAL_DEPLOY_TARGET_LINKS[@]}" -ne "$count" ]]; then
        echo "[ERR] WAL_DEPLOY_APP_NAMES, WAL_DEPLOY_CACHE_FILES and WAL_DEPLOY_TARGET_LINKS must be the same length" >&2
        return 1
    fi

    local i
    for (( i = 0; i < count; i++ )); do
        wal_deploy::link_one \
            "${WAL_DEPLOY_APP_NAMES[i]}" \
            "${WAL_DEPLOY_CACHE_FILES[i]}" \
            "${WAL_DEPLOY_TARGET_LINKS[i]}"
    done
}

wal_deploy::link_by_name() {
    local wanted="$1"
    local count="${#WAL_DEPLOY_APP_NAMES[@]}"
    local i

    for (( i = 0; i < count; i++ )); do
        if [[ "${WAL_DEPLOY_APP_NAMES[i]}" == "$wanted" ]]; then
            wal_deploy::link_one \
                "${WAL_DEPLOY_APP_NAMES[i]}" \
                "${WAL_DEPLOY_CACHE_FILES[i]}" \
                "${WAL_DEPLOY_TARGET_LINKS[i]}"
            return 0
        fi
    done

    echo "[ERR] Application '${wanted}' not found in WAL_DEPLOY_APP_NAMES" >&2
    return 1
}
