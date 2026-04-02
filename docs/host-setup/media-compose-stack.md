# Media Compose stack

This is the media automation step for the condo lab.

## Goal

Stand up one media stack that handles downloads, indexers, automation, and
requests with a shared filesystem layout that works cleanly with the NAS-backed
media library.

## Stack location

The stack definition lives in:

- `src/docker/media/`

## Included services

- `qBittorrent` for downloads
- `Gluetun` for PIA VPN routing for qBittorrent
- `Sonarr` for TV automation
- `Radarr` for movie automation
- `Prowlarr` for indexer management
- `FlareSolverr` for compatible indexer access
- `Overseerr` for user requests

## Setup flow

1. Copy `src/docker/media/.env.example` to `src/docker/media/.env`.
2. Confirm the external `ipvlan` Docker network already exists.
3. Confirm the NAS mounts for `/mnt/Files/Torrent-Data`, `/mnt/Media/Movies`,
   and `/mnt/Media/TV Shows` exist on the host.
4. Create host config directories for each service under
   `/condolab/docker/media/`.
5. Set the PIA credentials and Gluetun firewall env vars in `.env`.
6. Start the stack from `src/docker/media/`.
7. Open each web UI and finish the service-to-service wiring.

## Basic commands

From `src/docker/media/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/media/gluetun
mkdir -p /condolab/docker/media/qbittorrent/config
mkdir -p /condolab/docker/media/sonarr/config
mkdir -p /condolab/docker/media/radarr/config
mkdir -p /condolab/docker/media/prowlarr/config
mkdir -p /condolab/docker/media/overseerr/config
docker compose up -d
docker compose ps
docker compose logs -f qbittorrent
```

## Access pattern

- `qBittorrent` is routed through Traefik as `https://qbittorrent.zinkzone.tech`
- `qBittorrent` shares the `gluetun` network namespace, so the qBittorrent web
  UI and torrent ports are exposed through the Gluetun container
- `Gluetun` uses a dedicated bridge network as its primary network and also
  joins `ipvlan` so Traefik can still reach qBittorrent
- `Sonarr` is routed through Traefik as `https://sonarr.zinkzone.tech`
- `Radarr` is routed through Traefik as `https://radarr.zinkzone.tech`
- `Prowlarr` is routed through Traefik as `https://prowlarr.zinkzone.tech`
- `Overseerr` is routed through Traefik as `https://overseerr.zinkzone.tech`
- `FlareSolverr` is not exposed through Traefik, but it joins the shared
  `ipvlan` network so it can reach external sites for challenge solving
- qBittorrent also publishes torrent traffic on `6881` TCP and UDP
- the stack uses `ipvlan` for the general media apps, but the qBittorrent VPN
  pair also uses a dedicated bridge network because Gluetun expects a more
  conventional primary Docker interface

## Filesystem expectations

- downloads: `/mnt/Files/Torrent-Data`
- movies: `/mnt/Media/Movies`
- TV shows: `/mnt/Media/TV Shows`
- local app configs: `/condolab/docker/media/<service>/config`

Keep the same downloads path visible to qBittorrent, Sonarr, and Radarr so the
automation workflow can import completed files without path remapping.

## VPN notes

- Gluetun uses PIA over OpenVPN and provides the kill-switch boundary for
  qBittorrent
- qBittorrent should be configured from Sonarr and Radarr using
  `http://gluetun:8080` from inside the stack
- Review `GLUETUN_FIREWALL_OUTBOUND_SUBNETS` before first start so LAN access is
  only as broad as you intend

## Related docs

- [Plex Compose stack](plex-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Traefik Compose stack](traefik-compose-stack.md)
