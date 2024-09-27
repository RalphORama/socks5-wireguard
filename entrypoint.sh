#!/usr/bin/env bash

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



# WireGuard

if [ -z "${WIREGUARD_CONFIG}" ]; then
    log "ERROR" "Missing WireGuard config"
    exit 1
fi

cp -f "${WIREGUARD_CONFIG}" "/etc/wireguard/wg.conf"

log "INFO" "Starting WireGuard ..."

wg-quick up wg

if ! ip -o -f inet addr show dev wg; then
    log "ERROR" "Error during WireGuard startup"
    exit 1
fi

log "INFO" "WireGuard is running"



# 3proxy

log "INFO" "Starting 3proxy ..."

spawn 3proxy "/etc/3proxy.cfg"

log "INFO" "3proxy is running"



# iptables

# SUBNET=$(ip -o -f inet addr show dev eth0 | awk '{print $4}')
# IPADDR=$(echo "${SUBNET}" | cut -f1 -d'/')
# GATEWAY=$(route -n | grep 'UG[ \t]' | awk '{print $2}' | head -n 1)
# eval "$(ipcalc -np "${SUBNET}")"

# ip -4 rule del not fwmark 51820 table 51820
# ip -4 rule del table main suppress_prefixlength 0

# ip -4 rule add prio 10 from "${IPADDR}" table 128
# ip -4 route add table 128 to "${NETWORK}/${PREFIX}" dev eth0
# ip -4 route add table 128 default via "${GATEWAY}"

# ip -4 rule add prio 20 not fwmark 51820 table 51820
# ip -4 rule add prio 20 table main suppress_prefixlength 0

# log "INFO" "Updated iptables"




join
