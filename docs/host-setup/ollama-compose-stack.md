# llama.cpp Compose stack

This is the optional experimental inference step for Condolab.

## Goal

Stand up one local `llama.cpp` service that keeps GGUF models on the Docker host
and exposes them through the shared Traefik entrypoint for approved lab clients
and app stacks.

## Stack location

- `src/docker/ollama/`

## Included behavior

- runs one local llama.cpp HTTP server
- stores GGUF model files under `/condolab/docker/ollama/models`
- routes the service through Traefik as `https://ollama.zinkzone.tech`
- joins the shared `ipvlan` Docker network so other app stacks can call the API
  directly as `http://llamacpp:8080`
- mounts `/dev/dri` and uses the Vulkan build so the MS-01 can test Intel iGPU
  acceleration without Ollama in the middle

## Setup flow

1. Ensure the shared external `ipvlan` Docker network already exists.
2. Copy `src/docker/ollama/.env.example` to `src/docker/ollama/.env`.
3. Place a GGUF model file into `/condolab/docker/ollama/models`.
4. Start the stack from `src/docker/ollama/`.
5. Check the startup logs for Vulkan or GPU detection before relying on the
   stack for latency-sensitive workloads.
6. Test output correctness before assuming the Intel iGPU path is usable.

## Basic commands

From `src/docker/ollama/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/ollama/models
docker compose up -d
docker compose ps
docker compose logs -f llamacpp
```

## Storage notes

- GGUF models are large compared with normal app containers, so keep them on
  local fast storage rather than on a remote filesystem
- use one known-good small model first before testing larger files or multiple
  quantizations

## Operational notes

- keep this stack optional and experimental as described in issue `#40`
- if the model is not being used, stop the stack rather than letting it compete
  with primary always-on services
- route the external API through Traefik at `https://ollama.zinkzone.tech`
- note that existing Ollama clients will break because the service now exposes
  llama.cpp endpoints rather than Ollama's `/api/*` routes
- let app stacks on `ipvlan` call `http://llamacpp:8080` directly instead of
  creating another dedicated app network

## Validation and benchmarking

On `ms01`, confirm the container can see the GPU device:

```bash
cd /condolab/src/docker/ollama
docker compose exec llamacpp ls /dev/dri
docker compose logs llamacpp | grep -i -E 'vulkan|gpu|intel|render'
```

Then run one repeatable request and confirm both latency and output quality:

```bash
curl -s http://127.0.0.1:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Explain DNS.","n_predict":128,"temperature":0}' \
  | jq '{content, timings}'
```

If the logs never mention Vulkan or GPU initialization, assume the request is
still CPU-bound. If the response is fast but obviously corrupted, treat the
Intel Vulkan path as unstable and fall back to CPU.

## Related docs

- [KaraKeep Compose stack](karakeep-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
