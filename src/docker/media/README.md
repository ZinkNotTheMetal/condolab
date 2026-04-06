# Media Docker Compose stack

Media automation stack for the condo lab.

## Includes

- Sonarr for TV automation
- Radarr for movie automation
- Prowlarr for indexer management
- FlareSolverr for compatible indexer access
- Overseerr for media requests
- Traefik labels for the user-facing web apps

## Why

This stack keeps the day-to-day media workflow together so downloads, indexers,
library automation, and requests can share one set of paths and one deployment
boundary.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Ensure the external Docker `ipvlan` network already exists.
3. Confirm the NAS-backed media paths are mounted on the host.
4. Create the local config paths.
5. Start the stack.

```bash
cp .env.example .env
mkdir -p /condolab/docker/media/sonarr/config
mkdir -p /condolab/docker/media/radarr/config
mkdir -p /condolab/docker/media/prowlarr/config
mkdir -p /condolab/docker/media/overseerr/config
docker compose up -d
docker compose ps
docker compose logs -f qbittorrent
```

## Media paths

- downloads: `/mnt/Files/Torrent-Data`
- movies: `/mnt/Media/Movies`
- TV shows: `/mnt/Media/TV Shows`

## Service URLs

- `https://sonarr.zinkzone.tech`
- `https://radarr.zinkzone.tech`
- `https://prowlarr.zinkzone.tech`
- `https://overseerr.zinkzone.tech`

## Notes

- qBittorrent and Gluetun now live in the dedicated `src/docker/qbittorrent-vpn/`
  stack because the VPN routing model is operationally different from the rest
  of the media apps
- Sonarr and Radarr should connect to qBittorrent at `http://192.168.0.8:8080`
  unless a different internal route is introduced later
- FlareSolverr is not exposed through Traefik, but it does join the shared
  `ipvlan` network so it can resolve and reach external indexer endpoints
- Sonarr and Radarr still share the same downloads mount path that qBittorrent
  uses in the separate VPN stack so import paths stay consistent
- centralized logs will flow into Loki automatically through the host collector
- this stack assumes torrent data lives at `/mnt/Files/Torrent-Data`, so keep
  that mount consistent across qBittorrent, Sonarr, and Radarr
