# Plex Compose stack

This is the media server step for Condolab.

## Goal

Stand up Plex using the NAS-backed Movies and TV libraries while keeping Plex
configuration and temporary transcode data on the Docker host.

## Stack location

- `src/docker/plex/`

## Included behavior

- mounts Movies from `/mnt/Media/Movies`
- mounts TV shows from `/mnt/Media/TV Shows`
- stores Plex config under `/condolab/docker/plex/config`
- stores transcode scratch data under `/condolab/docker/plex/transcode`
- routes Plex through Traefik as `https://plex.zinkzone.tech`
- keeps direct port `32400` available for Plex-native clients that expect it

## Setup flow

1. Confirm Ansible has mounted `/mnt/Media` from the NAS.
2. Copy `src/docker/plex/.env.example` to `src/docker/plex/.env`.
3. Set `PUID`, `PGID`, timezone, and optional `PLEX_CLAIM`.
4. Create the local config and transcode directories.
5. Start the stack from `src/docker/plex/`.
6. Complete Plex library setup using the Movies and TV paths already mounted in
   the container.

## Basic commands

From `src/docker/plex/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/plex/config
mkdir -p /condolab/docker/plex/transcode
docker compose up -d
docker compose ps
docker compose logs -f plex
```

## Storage notes

- the large media library stays on the NAS through `/mnt/Media`
- Plex config stays local so metadata and database files are fast to access
- transcode data stays local because it is temporary working data rather than
  library data worth replicating

## Related docs

- [MS-01 Ansible bootstrap](ms-01-ansible-bootstrap.md)
- [Traefik Compose stack](traefik-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
