# qBittorrent VPN Docker Compose stack

Dedicated qBittorrent stack for the condo lab with Gluetun and Private Internet
Access.

## Includes

- Gluetun for the PIA OpenVPN tunnel and kill-switch boundary
- qBittorrent sharing the Gluetun network namespace
- host-published qBittorrent WebUI on port `8080`
- host-published torrent traffic on `6881` TCP and UDP
- Traefik integration through the shared host IP instead of Docker labels

## Why

This stack keeps the VPN-sensitive torrent client separate from the rest of the
media apps so Gluetun can use a conventional bridge network while Traefik still
reaches qBittorrent through the host LAN IP.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Set the PIA credentials and confirm the allowed outbound subnets.
3. Create the local config paths.
4. Start the stack.

```bash
cp .env.example .env
mkdir -p /condolab/docker/qbittorrent-vpn/gluetun
mkdir -p /condolab/docker/qbittorrent-vpn/qbittorrent/config
docker compose up -d
docker compose ps
docker compose logs -f gluetun
```

## Paths

- downloads: `/mnt/Files/Torrent-Data`
- gluetun state: `/condolab/docker/qbittorrent-vpn/gluetun`
- qBittorrent config: `/condolab/docker/qbittorrent-vpn/qbittorrent/config`

## Access

- qBittorrent UI: `https://qbittorrent.zinkzone.tech`
- direct host port: `http://192.168.0.8:8080`
- Sonarr and Radarr should use `http://192.168.0.8:8080` as the download client
  endpoint unless a different internal route is introduced later

## Notes

- qBittorrent uses `network_mode: service:gluetun`, so if Gluetun is down the
  torrent client loses network access by design
- Traefik reaches qBittorrent through a file-provider route to the host LAN IP
  because Gluetun is not attached to the `ipvlan` network
- centralized logs will still flow into Loki automatically through the host
  collector
- the LinuxServer qBittorrent image creates a temporary admin password on first
  start; retrieve it with `docker logs qbittorrent_app_ui | grep -i password`
