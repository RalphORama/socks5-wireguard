# socks5-wireguard - Create a SOCKS5 server using a WireGuard config

![GitHub License][3] ![GitHub Actions Workflow Status][4]

`socks5-wireguard` uses Docker to spin up a SOCKS5 server that proxies traffic
through a WireGuard connection.

## Usage

### With Docker Compose

An example `compose.yaml` is provided as [`compose.example.yaml`][1]. To use it,
follow these steps:

1. [Install Docker](https://docs.docker.com/engine/install/)
2. Download [`compose.example.yaml`][1] and save it as `compose.yaml` in a dedicated folder.
3. Edit the values in `compose.yaml` to your liking. (The defaults should be fine.)
4. Create a subdirectory next to `compose.yaml` named `socks5-wireguard`
5. Drop your WireGuard config file in that folder and name it `socks5-wireguard.conf`
6. Open a terminal, navigate to that folder, and type `docker compose up -d`
7. After \~30 seconds, two proxies should be available:
   - A SOCKS5 proxy at `localhost:1080`
   - A HTTP proxy at `localhost:3128`
8. Test to see if your proxy is working by running the following:

```bash
curl -f -x socks5h://127.0.0.1:1080 https://ifconfig.me
```

### With Docker

To run a standalone Docker container, follow these steps:

1. Download/create a WireGuard config file
2. Run the following command (replace `your_wireguard.conf` with the name of your config file):

```bash
SOCKS5_PROXY_PORT="1080"
HTTP_PROXY_PORT="3128"
WIREGUARD_CONFIG="your_wireguard.conf"
docker run \
  --name "socks5-wireguard" \
  -d --rm \
  --device=/dev/net/tun --cap-add=NET_ADMIN --privileged \
  -p "127.0.0.1:1080:1080" \
  -p "127.0.0.1:3128:3128"
  -v "${PWD}":/etc/socks5-wireguard:ro \
  ghcr.io/ralphorama/socks5-wireguard:latest
```


## LICENSE

**NB:** This project was originally licensed under the [WTFPL][2]. I forked
this repo from another fork that removed the WTFPL. I am licensing this repo
under the GNU AGPL v3. Since that is WTF I Want To :^)

```
socks5-wireguard - Create a SOCKS5 server using a WireGuard config
Copyright (C) 2025  Audrey Drake

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


[1]: https://github.com/RalphORama/socks5-wireguard/blob/main/compose.example.yaml
[2]: https://github.com/curve25519xsalsa20poly1305/docker-wireguard/blob/master/COPYING
[3]: https://img.shields.io/github/license/ralphorama/socks5-wireguard?style=plastic
[4]: https://img.shields.io/github/actions/workflow/status/ralphorama/socks5-wireguard/docker.yml?branch=main&event=push&style=plastic
