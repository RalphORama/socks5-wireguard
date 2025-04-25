#!/usr/bin/env bash
set -euo pipefail

THREEPROXY_CFG='/etc/3proxy/3proxy.cfg'
WIREGUARD_CONFIG="/etc/socks5-wireguard/${WIREGUARD_CONFIG}"

function log {
    local LEVEL="$1"
    local MSG="$(date '+%D %T') [${LEVEL}] $2"
    case "${LEVEL}" in
        INFO*)      MSG="\x1B[94m${MSG}";;
        WARNING*)   MSG="\x1B[93m${MSG}";;
        ERROR*)     MSG="\x1B[91m${MSG}";;
        *)
    esac
    echo -e "${MSG}"
}

function spawn {
    if [[ -z ${PIDS+x} ]]; then PIDS=(); fi
    "$@" &
    PIDS+=($!)
}

function join {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            wait "${pid}"
        done
    fi
}

function on_kill {
    if [[ ! -z ${PIDS+x} ]]; then
        for pid in "${PIDS[@]}"; do
            kill "${pid}" 2> /dev/null
        done
    fi
    kill "${ENTRYPOINT_PID}" 2> /dev/null
}

export ENTRYPOINT_PID="${BASHPID}"

trap "on_kill" EXIT
trap "on_kill" SIGINT

if ! [ -f "${WIREGUARD_CONFIG}" ]; then
    log "ERROR" "${WIREGUARD_CONFIG} does not exist!"
    exit 1
fi

if [ ! -f "${THREEPROXY_CFG}" ]; then
    log "ERROR" "3proxy.cfg does not exist!"
    exit 1
fi

log "INFO" "Copying '${WIREGUARD_CONFIG}' to /etc/wireguard/wg0.conf"
cp -f "${WIREGUARD_CONFIG}" "/etc/wireguard/wg0.conf"


log "INFO" "Starting WireGuard..."
wg-quick up wg0

if ! ip -o -f inet addr show dev wg0; then
    log "ERROR" "Error during WireGuard startup"
    exit 1
fi

log "INFO" "WireGuard is running"

log "INFO" "Populating values in ${THREEPROXY_CFG}..."
sed -E -i "s/^socks -p[[:digit:]]+$/socks -p${SOCKS5_PROXY_PORT}/" "${THREEPROXY_CFG}"
sed -E -i "s/^proxy -p[[:digit:]]+$/socks -p${HTTP_PROXY_PORT}/" "${THREEPROXY_CFG}"

# 3proxy
log "INFO" "Starting 3proxy..."
spawn 3proxy "${THREEPROXY_CFG}"
log "INFO" "3proxy is running"

log "INFO" "Executing 'join' function..."
join
log "INFO" "Done with 'join' function"
