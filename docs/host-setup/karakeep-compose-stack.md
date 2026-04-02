# KaraKeep Compose stack

This is the bookmark and AI-assisted capture step for Condolab.

## Goal

Stand up KaraKeep with local search and optional Ollama-backed tagging so the
lab can test whether a small local model adds enough value to keep the
experimental AI stack around.

## Stack location

- `src/docker/karakeep/`

## Included behavior

- runs KaraKeep behind Traefik as `https://karakeep.zinkzone.tech`
- uses Meilisearch for local indexing
- uses a headless Chrome sidecar for crawling and richer page capture
- connects to Ollama over the shared `ipvlan` network
- stores application data under `/condolab/docker/karakeep/data`
- stores Meilisearch data under `/condolab/docker/karakeep/meilisearch`

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Confirm the Ollama stack is running and `qwen2.5:3b` has been pulled.
3. Copy `src/docker/karakeep/.env.example` to `src/docker/karakeep/.env`.
4. Generate the required secrets and set the final routed hostname if needed.
5. Ensure the external `ipvlan` Docker network already exists.
6. Create the local storage directories.
7. Start the stack from `src/docker/karakeep/`.
8. Verify KaraKeep loads through Traefik and test one saved bookmark with AI
   tagging enabled.

Use the prefixed KaraKeep secret names in `.env` or Infisical:

- `KARAKEEP_NEXTAUTH_URL`
- `KARAKEEP_NEXTAUTH_SECRET`
- `KARAKEEP_MEILI_MASTER_KEY`

The Compose file maps those values back to the container variable names that
KaraKeep and Meilisearch actually require.

## Basic commands

From `src/docker/karakeep/`:

```bash
cp .env.example .env
chmod 600 .env
mkdir -p /condolab/docker/karakeep/data
mkdir -p /condolab/docker/karakeep/meilisearch
docker compose up -d
docker compose ps
docker compose logs -f web
```

## AI notes

- KaraKeep points at Ollama with `OLLAMA_BASE_URL=http://ollama:11434`
- the first configuration uses `qwen2.5:3b` for text inference only
- summarization stays off by default so the first experiment focuses on cheaper
  tagging and classification behavior
- if tagging latency is too high, raise `INFERENCE_JOB_TIMEOUT_SEC` before
  increasing concurrency

## Networking notes

- `web` joins the shared `ipvlan` network for Traefik routing
- `web` also reaches Ollama on the same shared `ipvlan` network as
  `http://ollama:11434`
- `chrome` and `meilisearch` remain private to the stack

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [Ollama Compose stack](ollama-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
