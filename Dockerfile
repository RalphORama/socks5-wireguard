FROM alpine:3.20

# Install 3proxy to /usr/local/bin
ARG THREEPROXY_VERSION=0.9.4
RUN apk add alpine-sdk && \
    export DIR=$(mktemp -d) && cd $DIR && \
    wget https://github.com/3proxy/3proxy/archive/refs/tags/${THREEPROXY_VERSION}.tar.gz && tar -xf ${THREEPROXY_VERSION}.tar.gz && mv 3proxy* 3proxy && \
    cd 3proxy && \
    make -f Makefile.Linux || true && \
    mv bin/3proxy /usr/local/bin/ && \
    cd && rm -rf $DIR && \
    apk del alpine-sdk

# Install other dependencies
RUN apk add --no-cache bash curl wget wireguard-tools openresolv ip6tables libgcc libstdc++ gnutls expat sqlite-libs c-ares openssl

# Prepare entrypoint and configuration
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY 3proxy.cfg /etc/3proxy.cfg

# Wireguard Options
ENV     WIREGUARD_CONFIG                ""
ENV     WIREGUARD_UP                    ""

# Proxy Options
ENV     PROXY_UP                        ""

# Proxy Ports Options
ENV     SOCKS5_PROXY_PORT               "1080"
ENV     HTTP_PROXY_PORT                 "3128"

ENV     DAEMON_MODE                     "false"

ENTRYPOINT  [ "entrypoint.sh" ]
