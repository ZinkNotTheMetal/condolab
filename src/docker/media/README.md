# Media Docker Compose stack

Media automation stack for the condo lab.

## Includes

- qBittorrent for downloads
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
mkdir -p /condolab/docker/media/qbittorrent/config
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

- `https://qbittorrent.zinkzone.tech`
- `https://sonarr.zinkzone.tech`
- `https://radarr.zinkzone.tech`
- `https://prowlarr.zinkzone.tech`
- `https://overseerr.zinkzone.tech`

## Notes

- FlareSolverr stays internal to the stack because only the indexer workflow
  needs it
- qBittorrent publishes `6881` TCP and UDP directly for torrent traffic while
  the web UI stays behind Traefik
- Sonarr, Radarr, and qBittorrent share the same downloads mount so import paths
  stay consistent
- centralized logs will flow into Loki automatically through the host collector
- this stack assumes torrent data lives at `/mnt/Files/Torrent-Data`, so keep
  that mount consistent across qBittorrent, Sonarr, and Radarr
