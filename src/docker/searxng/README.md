# SearXNG Docker Compose stack

Private metasearch stack for the condo lab.

## Includes

- SearXNG web application
- Valkey for cache and limiter support
- Traefik labels for the `search.zinkzone.tech` endpoint

## Why

This stack gives the lab one privacy-friendly search entrypoint that can reduce
ad-heavy search noise, keep search habits out of third-party profiles, and act
as a clean backend for future AI search workflows.

## Files

- `compose.yaml`
- `.env.example`
- `settings.yml`

## Usage

1. Copy `.env.example` to `.env`.
2. Replace the placeholder `secret_key` in `settings.yml`.
3. Ensure the external Docker `ipvlan` network already exists.
4. Create the local data paths.
5. Start the stack.

```bash
cp .env.example .env
openssl rand -hex 32
mkdir -p /condolab/docker/searxng/cache
mkdir -p /condolab/docker/searxng/valkey
docker compose up -d
docker compose ps
docker compose logs -f searxng
```

## Service URL

- `https://search.zinkzone.tech`

## Notes

- this stack assumes a private lab-first deployment, so `server.limiter` stays
  off until you expose the service beyond trusted clients
- SearXNG joins the shared `ipvlan` network for Traefik routing while Valkey
  stays private to the stack
- centralized logs will flow into Loki automatically through the host collector
- `image_proxy` stays on so search result image loads do not hand your client IP
  directly to upstream sites
- the first useful AI follow-on is wiring SearXNG into an answer engine such as
  Open WebUI or Perplexica instead of using it only as a browser homepage
