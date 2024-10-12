# WireGuard to SOCKS5/HTTP Proxy Docker Image

[Original source](https://github.com/curve25519xsalsa20poly1305/docker-wireguard)

Convers WireGuard connection to SOCKS5/HTTP proxy in Docker.

## What it does?

1. It reads in a WireGuard configuration file (`.conf`) from a mounted file, specified through `WIREGUARD_CONFIG` environment variable.
2. It starts the WireGuard client program to establish the VPN connection.
3. It optionally runs the executable defined by `WIREGUARD_UP` when the VPN connection is stable.
4. It starts [3proxy](https://3proxy.ru/) server and listen on container-scoped port 1080 for SOCKS5 and 3128 for HTTP proxy on default. `SOCKS5_PROXY_PORT` and `HTTP_PROXY_PORT` can be used to change the default ports.
5. It optionally runs the executable defined by `PROXY_UP` when the proxy server is ready.
6. It optionally runs the user specified CMD line from `docker run` positional arguments ([see Docker doc](https://docs.docker.com/engine/reference/run/#cmd-default-command-or-options)). The program will use the VPN connection inside the container.
7. If user has provided CMD line, and `DAEMON_MODE` environment variable is not set to `true`, then after running the CMD line, it will shutdown the OpenVPN client and terminate the container.

## How to use?

WireGuard connection options are specified through these container environment variables:

- `WIREGUARD_CONFIG` (Default: `""`) - WireGuard config path.
- `WIREGUARD_UP` (Default: `""`) - Optional command to be executed when WireGuard connection becomes stable

Proxy server options are specified through these container environment variables:

- `SOCKS5_PROXY_PORT` (Default: `"1080"`) - SOCKS5 server listening port
- `HTTP_PROXY_PORT` (Default: `"3128"`) - HTTP proxy server listening port
- `PROXY_UP` (Default: `""`) - Optional command to be executed when proxy server becomes stable

Other container environment variables:

- `DAEMON_MODE` (Default: `"false"`) - force enter daemon mode when CMD line is specified
