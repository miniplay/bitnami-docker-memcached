#!/bin/bash

# shellcheck disable=SC1090

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. "${BITNAMI_SCRIPTS_DIR:-}"/liblog.sh
. "${BITNAMI_SCRIPTS_DIR:-}"/libos.sh
. "${BITNAMI_SCRIPTS_DIR:-}"/libmemcached.sh

# Load Memcached environment variables
. "${BITNAMI_SCRIPTS_DIR:-}"/memcached-env.sh

# Constants
EXEC=$(command -v memcached)

# Configure arguments with extra flags
args=("-u" "${MEMCACHED_DAEMON_USER}" "-p" "${MEMCACHED_PORT_NUMBER}" "$(memcached_debug_flags)")
# SASL
if [[ -f "${SASL_DB_FILE}" ]]; then
    args+=("-S")
fi
# Memory configuration
if [[ -n "${MEMCACHED_CACHE_SIZE}" ]]; then
    args+=("-m" "${MEMCACHED_CACHE_SIZE}")
fi
if [[ -n "$MEMCACHED_MAX_CONNECTIONS" ]]; then
    args+=("-c" "${MEMCACHED_MAX_CONNECTIONS}")
fi
if [[ -n "${MEMCACHED_THREADS}" ]]; then
    args+=("-t" "${MEMCACHED_THREADS}")
fi
args+=("$@")

info "** Starting Memcached **"
if am_i_root; then
    exec gosu "${MEMCACHED_DAEMON_USER}" "${EXEC}" "${args[@]}"
else
    exec "${EXEC}" "${args[@]}"
fi
