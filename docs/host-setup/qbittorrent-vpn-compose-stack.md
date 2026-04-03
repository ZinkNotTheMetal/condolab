# qBittorrent VPN Compose stack

This is the dedicated torrent client step for the condo lab.

## Goal

Stand up qBittorrent behind Private Internet Access using Gluetun on a normal
bridge network, while still exposing the qBittorrent WebUI through Traefik by
routing to the host LAN IP.

## Stack location

The stack definition lives in:

- `src/docker/qbittorrent-vpn/`

## Included services

- `Gluetun` for the PIA OpenVPN tunnel and kill-switch behavior
- `qBittorrent` for torrent downloads using Gluetun's network namespace

## Setup flow

1. Copy `src/docker/qbittorrent-vpn/.env.example` to
   `src/docker/qbittorrent-vpn/.env`.
2. Set the PIA credentials and confirm the allowed LAN and Docker subnets.
3. Create host config directories under `/condolab/docker/qbittorrent-vpn/`.
4. Start the stack from `src/docker/qbittorrent-vpn/`.
5. Confirm Gluetun becomes healthy before qBittorrent starts.
6. Access qBittorrent through Traefik or the direct host port and finish the
   qBittorrent setup.

## Basic commands

From `src/docker/qbittorrent-vpn/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/qbittorrent-vpn/gluetun
mkdir -p /condolab/docker/qbittorrent-vpn/qbittorrent/config
docker compose up -d
docker compose ps
docker compose logs -f gluetun
```

## Access pattern

- Traefik routes `https://qbittorrent.zinkzone.tech` to `http://192.168.0.8:8080`
- qBittorrent is also available directly on `http://192.168.0.8:8080`
- torrent traffic is published on `6881` TCP and UDP on the host
- Sonarr and Radarr should use `http://192.168.0.8:8080` for the qBittorrent
  download client configuration

## Filesystem expectations

- downloads: `/mnt/Files/Torrent-Data`
- Gluetun state: `/condolab/docker/qbittorrent-vpn/gluetun`
- qBittorrent config: `/condolab/docker/qbittorrent-vpn/qbittorrent/config`

## Notes

- qBittorrent shares Gluetun's network namespace, so VPN failure removes its
  network path automatically
- this stack stays off `ipvlan` because that network model caused Gluetun to
  fail on startup in testing
- Traefik integration uses the file provider instead of Docker labels because
  the reachable endpoint is the host LAN IP and port

## Related docs

- [Media Compose stack](media-compose-stack.md)
- [Traefik Compose stack](traefik-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
