# Plex Docker Compose stack

Plex media server stack for the condo lab.

## Includes

- Plex Media Server
- NAS-backed movie and TV libraries
- local transcode path on the host
- Traefik labels for the `plex.zinkzone.tech` endpoint

## Why

This stack keeps the large media libraries on the NAS while using the Docker
host only for Plex configuration and temporary transcode files.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Set the correct `PUID`, `PGID`, and optional `PLEX_CLAIM` token.
3. Create the local config and transcode paths:

```bash
mkdir -p /condolab/docker/plex/config
mkdir -p /condolab/docker/plex/transcode
```

1. Start the stack:

```bash
docker compose up -d
```

1. Verify:

```bash
docker compose ps
docker compose logs -f plex
```

## Media paths

- movies: `/mnt/Media/Movies`
- TV shows: `/mnt/Media/TV Shows`

## Notes

- the NAS media mounts come from the Ansible-managed `/mnt/Media` mount
- transcode files can remain local to the machine because they are temporary and
  should not be replicated with the media library
- the stack publishes port `32400` directly for Plex-native clients while also
  exposing Plex through Traefik at `https://plex.zinkzone.tech`
- centralized logs will flow into Loki automatically through the host collector
