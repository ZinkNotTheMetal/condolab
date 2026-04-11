# DocuSeal Compose stack

This is the private document signing step for Condolab.

## Goal

Stand up DocuSeal behind Traefik so trusted lab users can upload, fill, and
sign PDF documents without relying on a cloud-only signature platform.

## Stack location

- `src/docker/docuseal/`

## Included behavior

- runs DocuSeal behind Traefik as `https://sign.zinkzone.tech`
- uses the upstream default SQLite-backed setup to keep the private deployment
  small and avoid a separate secrets file
- stores DocuSeal files, SQLite data, and generated runtime secrets under
  `/condolab/docker/docuseal/data`
- joins the shared `ipvlan` Docker network for Traefik routing

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Ensure the external `ipvlan` Docker network already exists.
3. Create the local storage directory.
4. Start the stack from `src/docker/docuseal/`.
5. Open DocuSeal through Traefik and complete the first-run admin setup.
6. Upload one test PDF and verify a private signing flow end to end.

## Basic commands

From `src/docker/docuseal/`:

```bash
mkdir -p /condolab/docker/docuseal/data
docker compose up -d
docker compose ps
docker compose logs -f docuseal
```

## Operational notes

- DocuSeal upstream supports SQLite by default, and this stack keeps that path
  because it removes the need for a `.env` file in a private single-instance
  deployment
- DocuSeal can generate its own runtime `SECRET_KEY_BASE` inside the mounted
  data directory on first boot, which keeps the initial setup small while still
  persisting the generated secret across restarts
- `FORCE_SSL=true` is set because TLS terminates at Traefik and DocuSeal should
  treat external requests as HTTPS
- the Traefik router also injects explicit `X-Forwarded-Proto` and
  `X-Forwarded-Host` headers so DocuSeal can validate request origin correctly
  and avoid reverse-proxy `422 InvalidAuthenticityToken` failures
- keep this route private or protected at the edge because the first run creates
  the initial admin account in the web UI

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [CloudBeaver Compose stack](cloudbeaver-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
