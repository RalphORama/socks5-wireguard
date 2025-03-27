FROM alpine:3.20

# Install dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    ip6tables \
    wireguard-tools

# Crazy workaround for 3proxy installations failing
# see https://gitlab.alpinelinux.org/alpine/aports/-/issues/15543#note_493627
RUN addgroup -S 3proxy && \
    adduser -S -D -h /var/log/3proxy -s /sbin/nologin -G 3proxy -g 3proxy 3proxy && \
    rm -rf /var/log/3proxy && \
    touch /var/log/3proxy && \
    chown 3proxy:3proxy /var/log/3proxy && \
    apk -vv add \
        --no-cache \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        3proxy

RUN mkdir -p /etc/socks5-wireguard /etc/3proxy

# Prepare entrypoint and configuration
COPY entrypoint.sh /usr/local/bin/
COPY 3proxy.cfg /etc/defaults/3proxy.cfg

# Wireguard Options
ENV WIREGUARD_CONFIG    "socks5-wireguard.conf"

# 3proxy Ports configuration
ENV SOCKS5_PROXY_PORT="1080"
ENV HTTP_PROXY_PORT="3128"

RUN mkdir -p /etc/socks5-wireguard

VOLUME [ "/etc/socks5-wireguard" ]
VOLUME [ "/etc/3proxy" ]

ENTRYPOINT  [ "entrypoint.sh" ]
