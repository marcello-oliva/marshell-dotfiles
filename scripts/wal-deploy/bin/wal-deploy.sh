#!/usr/bin/env bash
set -euo pipefail

# ──── Configuration ───────────────────────────
readonly WAL_DEPLOY_BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly WAL_DEPLOY_CONF_DIR="${WAL_DEPLOY_BIN_DIR}/../config"
readonly WAL_DEPLOY_LIB_DIR="${WAL_DEPLOY_BIN_DIR}/../lib"

# Explicit sourcing order: config must load before functions.
source "${WAL_DEPLOY_CONF_DIR}/constants.sh"
source "${WAL_DEPLOY_LIB_DIR}/functions.sh"

# ──── Entrypoint ────────────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
    wal_deploy::link_by_name "$1"
else
    wal_deploy::link_all
fi
