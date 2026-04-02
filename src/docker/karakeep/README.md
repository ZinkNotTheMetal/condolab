# KaraKeep Docker Compose stack

Bookmark capture and AI-assisted tagging stack for the condo lab.

## Includes

- KaraKeep web application
- Meilisearch for local search indexing
- headless Chrome for richer crawling
- local Ollama integration over the shared `ipvlan` network
- Traefik labels for the `karakeep.zinkzone.tech` endpoint

## Why

This stack gives the lab one place to save links, notes, and captured content
while proving whether a small local model is useful enough to justify keeping
the experimental AI stack around.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Ensure the external Docker `ipvlan` network already exists.
3. Create the local data paths.
4. Start Ollama and pull `qwen2.5:3b` before enabling AI tagging.
5. Start KaraKeep.

Use the prefixed secret names in `.env` or Infisical, then let Compose map them
back to the container names KaraKeep expects:

- `KARAKEEP_NEXTAUTH_URL` -> `NEXTAUTH_URL`
- `KARAKEEP_NEXTAUTH_SECRET` -> `NEXTAUTH_SECRET`
- `KARAKEEP_MEILI_MASTER_KEY` -> `MEILI_MASTER_KEY`

```bash
cp .env.example .env
mkdir -p /condolab/docker/karakeep/data
mkdir -p /condolab/docker/karakeep/meilisearch
docker compose up -d
docker compose ps
docker compose logs -f web
```

## Notes

- KaraKeep reaches Ollama over `http://ollama:11434` on the shared
  `ipvlan` network
- prefixed secret names are mapped in Compose so Infisical can keep KaraKeep
  secrets distinct from other apps
- Meilisearch and Chrome remain private to the stack and are not exposed on the
  LAN
- the application is routed through Traefik as `https://karakeep.zinkzone.tech`
- centralized logs will flow into Loki automatically through the host collector
- `INFERENCE_ENABLE_AUTO_SUMMARIZATION` stays off by default so the first model
  experiment focuses on lower-cost tagging rather than longer generations
