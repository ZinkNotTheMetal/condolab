# LazyLibrarian Compose stack

This is the ebook and audiobook library automation step for Condolab.

## Goal

Stand up LazyLibrarian behind Traefik so trusted lab users can manage book
metadata, monitor authors, and automate imports into the NAS-backed books
library.

## Stack location

- `src/docker/lazylibrarian/`

## Included behavior

- runs LazyLibrarian behind Traefik as `https://library.zinkzone.tech`
- stores LazyLibrarian config under `/condolab/docker/lazylibrarian/config`
- reads downloads from `/mnt/Files/Torrent-Data`
- reads and manages the books library under `/mnt/Media/Books`
- joins the shared `ipvlan` Docker network for Traefik routing

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Confirm the external `ipvlan` Docker network already exists.
3. Confirm the NAS mounts for `/mnt/Files/Torrent-Data` and `/mnt/Media/Books`
   exist on the host.
4. Create the local config directory.
5. Start the stack from `src/docker/lazylibrarian/`.
6. Open LazyLibrarian through Traefik and complete the first-run setup.
7. Configure download handling, metadata providers, and library paths in the web
   UI.

## Basic commands

From `src/docker/lazylibrarian/`:

```bash
mkdir -p /condolab/docker/lazylibrarian/config
docker compose up -d
docker compose ps
docker compose logs -f lazylibrarian
```

## Operational notes

- the LinuxServer image expects `/config`, `/downloads`, and `/books`, so the
  host mounts follow that shape directly to avoid path remapping later
- the upstream web UI is served at `/home`, but Traefik should route the main
  hostname cleanly to the application entrypoint
- this stack uses fixed local defaults for `PUID`, `PGID`, and timezone to keep
  startup simple and avoid a separate `.env` file

## Related docs

- [Media Compose stack](media-compose-stack.md)
- [qBittorrent VPN Compose stack](qbittorrent-vpn-compose-stack.md)
- [Traefik Compose stack](traefik-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
