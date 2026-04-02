# Ollama Docker Compose stack

Experimental local inference stack for the condo lab.

## Includes

- Ollama API server
- persistent local model storage under `/condolab/docker/ollama/models`
- Traefik labels for the `ollama.zinkzone.tech` endpoint
- shared `ipvlan` network access for routed traffic and app-to-model traffic

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
- model downloads can take time on the first pull and will consume disk under
  `/condolab/docker/ollama/models`
- centralized logs will flow into Loki automatically through the host collector
