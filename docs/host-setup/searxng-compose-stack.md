# SearXNG Compose stack

This is the private metasearch step for Condolab.

## Goal

Stand up one privacy-friendly search service behind Traefik so trusted lab
clients can use a cleaner search experience now and future AI workloads can use
one local search backend later.

## Stack location

- `src/docker/searxng/`

## Included behavior

- runs SearXNG behind Traefik as `https://search.zinkzone.tech`
- uses Valkey for cache support and future limiter support
- stores SearXNG cache under `/condolab/docker/searxng/cache`
- stores Valkey data under `/condolab/docker/searxng/valkey`
- joins the shared `ipvlan` Docker network for Traefik routing

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Copy `src/docker/searxng/.env.example` to `src/docker/searxng/.env`.
3. Replace the placeholder `secret_key` in `src/docker/searxng/settings.yml`.
4. Ensure the external `ipvlan` Docker network already exists.
5. Create the local storage directories.
6. Start the stack from `src/docker/searxng/`.
7. Verify SearXNG loads through Traefik and test a few engines from a trusted
   client.

## Basic commands

From `src/docker/searxng/`:

```bash
cp .env.example .env
openssl rand -hex 32
mkdir -p /condolab/docker/searxng/cache
mkdir -p /condolab/docker/searxng/valkey
docker compose up -d
docker compose ps
docker compose logs -f searxng
```

## Configuration notes

- set `SEARXNG_BASE_URL` in `.env` to the final routed hostname
- replace `ultrasecretkey` in `settings.yml` before first start
- keep `server.limiter` off while the service remains private-only
- turn `server.limiter` on before exposing the service outside trusted clients

## Why this one is useful

- it simplifies day-to-day search by removing some ads and result clutter
- it creates one reusable backend for AI tools that need web search
- it keeps your search entrypoint under your control instead of tying that habit
  to one commercial search profile

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [Ollama Compose stack](ollama-compose-stack.md)
- [KaraKeep Compose stack](karakeep-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
