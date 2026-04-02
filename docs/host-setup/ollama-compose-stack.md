# Ollama Compose stack

This is the optional experimental inference step for Condolab.

## Goal

Stand up one local Ollama service that keeps small models on the Docker host and
exposes them through the shared Traefik entrypoint for approved lab clients and
app stacks.

## Stack location

- `src/docker/ollama/`

## Included behavior

- runs one local Ollama API service
- stores models under `/condolab/docker/ollama/models`
- routes Ollama through Traefik as `https://ollama.zinkzone.tech`
- joins the shared `ipvlan` Docker network so other app stacks can call the API
  directly as `http://ollama:11434`

## Setup flow

1. Ensure the shared external `ipvlan` Docker network already exists.
2. Create the local model storage directory.
3. Start the stack from `src/docker/ollama/`.
4. Pull `qwen2.5:3b` into the local model cache.
5. Confirm the model is available before wiring app stacks to it.

## Basic commands

From `src/docker/ollama/`:

```bash
mkdir -p /condolab/docker/ollama/models
docker compose up -d
docker compose ps
docker compose exec ollama ollama pull qwen2.5:3b
docker compose exec ollama ollama list
```

## Storage notes

- models are large compared with normal app containers, so keep them on local
  fast storage rather than on a remote filesystem
- the first pull will consume the most network and disk activity
- later pulls reuse the same local cache under `/condolab/docker/ollama/models`

## Operational notes

- keep this stack optional and experimental as described in issue `#40`
- if the model is not being used, stop the stack rather than letting it compete
  with primary always-on services
- route the external API through Traefik at `https://ollama.zinkzone.tech`
- let app stacks on `ipvlan` call `http://ollama:11434` directly instead of
  creating another dedicated app network

## Related docs

- [KaraKeep Compose stack](karakeep-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
