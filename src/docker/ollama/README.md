# Ollama Docker Compose stack

Experimental local inference stack for the condo lab.

## Includes

- Ollama API server
- persistent local model storage under `/condolab/docker/ollama/models`
- Traefik labels for the `ollama.zinkzone.tech` endpoint
- shared `ipvlan` network access for routed traffic and app-to-model traffic
- Intel iGPU access through `/dev/dri` with Vulkan enabled for experimental GPU
  offload

## Why

This stack keeps local model serving isolated from the primary always-on service
groups while still making the API reachable through the existing Traefik entry
point for approved lab clients and app stacks.

## Files

- `compose.yaml`

## Usage

1. Ensure the external Docker `ipvlan` network exists.
2. Create the model storage path.
3. Start the stack.
4. Pull the first model after the API is up.

```bash
mkdir -p /condolab/docker/ollama/models
docker compose up -d
docker compose ps
docker compose exec ollama ollama pull qwen2.5:3b
docker compose exec ollama ollama list
```

## Notes

- the API is routed through Traefik as `https://ollama.zinkzone.tech`
- other Compose stacks on the shared `ipvlan` network can reach the service
  using `http://ollama:11434`
- the container enables `OLLAMA_VULKAN=1` and mounts `/dev/dri` so the MS-01 can
  attempt Intel iGPU acceleration through Vulkan
- model downloads can take time on the first pull and will consume disk under
  `/condolab/docker/ollama/models`
- centralized logs will flow into Loki automatically through the host collector

## Quick validation

On the host after the stack starts:

```bash
docker compose exec ollama ls /dev/dri
docker compose logs ollama | grep -i -E 'vulkan|gpu|intel|render'
```

For a repeatable single-request benchmark:

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
