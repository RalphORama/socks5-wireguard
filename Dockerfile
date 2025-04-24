FROM alpine:3.20

LABEL org.opencontainers.image.title="socks5-wireguard"
LABEL org.opencontainers.image.description="Create a SOCKS5 server using a WireGuard config"
LABEL org.opencontainers.image.authors="RalphORama"
LABEL org.opencontainers.image.url="https://github.com/RalphORama/socks5-wireguard/pkgs/container/socks5-wireguard"
LABEL org.opencontainers.image.documentation="https://github.com/RalphORama/socks5-wireguard/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/RalphORama/socks5-wireguard.git"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"

# Install dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    ip6tables \
    wireguard-tools

# install 3proxy from testing repo
RUN apk add \
    --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    3proxy

RUN mkdir -p /etc/socks5-wireguard /etc/3proxy

# Prepare entrypoint and configuration
COPY entrypoint.sh /usr/local/bin/
COPY 3proxy.cfg /etc/defaults/3proxy.cfg

# Wireguard Options
ENV WIREGUARD_CONFIG="socks5-wireguard.conf"

# 3proxy Ports configuration
ENV SOCKS5_PROXY_PORT="1080"
ENV HTTP_PROXY_PORT="3128"

RUN mkdir -p /etc/socks5-wireguard

VOLUME [ "/etc/socks5-wireguard" ]
VOLUME [ "/etc/3proxy" ]

ENTRYPOINT  [ "entrypoint.sh" ]
