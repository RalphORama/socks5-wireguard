#!/usr/bin/env bash
set -e

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

export ENTRYPOINT_PID="${BASHPID}"

trap "on_kill" EXIT
trap "on_kill" SIGINT

WIREGUARD_CONFIG="/etc/socks5-wireguard/${WIREGUARD_CONFIG}"

if ! [ -f "${WIREGUARD_CONFIG}" ]; then
    log "ERROR" "${WIREGUARD_CONFIG} does not exist!"
    exit 1
fi

if [ ! -f "/etc/3proxy/3proxy.cfg" ]; then
    log "WARNING" "/etc/3proxy/3proxy.cfg does not exist! Copying it from /etc/defaults/3proxy.cfg"
    cp "/etc/defaults/3proxy.cfg" "/etc/3proxy/3proxy.cfg"
fi

log "INFO" "Copying '${WIREGUARD_CONFIG}' to /etc/wireguard/wg0.conf"
cp -f "${WIREGUARD_CONFIG}" "/etc/wireguard/wg0.conf"

log "INFO" "Starting WireGuard"
wg-quick up wg0

if ! ip -o -f inet addr show dev wg0; then
    log "ERROR" "Error during WireGuard startup"
    exit 1
fi

log "INFO" "WireGuard is running"

log "INFO" "Populating values in /etc/3proxy/3proxy.cfg"
sed -E -i "s/^socks -p[[:digit:]]+$/socks -p${SOCKS5_PROXY_PORT}/" /etc/3proxy/3proxy.cfg
sed -E -i "s/^proxy -p[[:digit:]]+$/socks -p${HTTP_PROXY_PORT}/" /etc/3proxy/3proxy.cfg

# 3proxy
log "INFO" "Starting 3proxy"
spawn 3proxy "/etc/3proxy/3proxy.cfg"
log "INFO" "3proxy is running"

join
