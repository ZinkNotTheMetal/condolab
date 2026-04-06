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
- mounts `/dev/dri` and enables Vulkan so the MS-01 can attempt Intel iGPU
  acceleration

## Setup flow

1. Ensure the shared external `ipvlan` Docker network already exists.
2. Create the local model storage directory.
3. Start the stack from `src/docker/ollama/`.
4. Pull `qwen2.5:3b` into the local model cache.
5. Confirm the model is available before wiring app stacks to it.
6. Check the startup logs for Vulkan or GPU detection before relying on the
   stack for latency-sensitive workloads.

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

## Validation and benchmarking

On `ms01`, confirm the container can see the GPU device:

```bash
cd /condolab/src/docker/ollama
docker compose exec ollama ls /dev/dri
docker compose logs ollama | grep -i -E 'vulkan|gpu|intel|render'
```

Then run one repeatable request before and after the GPU change and compare the
reported `tokens_per_second` value:

```bash
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"qwen2.5:3b","prompt":"Explain DNS briefly.","stream":false}' \
  | jq '{
    total_duration_s:(.total_duration/1000000000),
    eval_count,
    eval_duration_s:(.eval_duration/1000000000),
    tokens_per_second:(.eval_count / (.eval_duration/1000000000))
  }'
```

If the logs never mention Vulkan or GPU initialization, assume the request is
still CPU-bound.

## Related docs

- [KaraKeep Compose stack](karakeep-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
