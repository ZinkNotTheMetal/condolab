# Monitoring Compose stack

This is the centralized logging step for the condo lab.

## Goal

Stand up one monitoring stack that collects Docker container logs from the host,
stores them in Loki, and makes them searchable in Grafana early in the lab
build.

## Stack location

The stack definition lives in:

- `src/docker/monitoring/`

## Included services

- `loki` for centralized log storage
- `grafana` for dashboards and log search
- `alloy` for Docker log discovery and forwarding

## Setup flow

1. Copy `src/docker/monitoring/.env.example` to
   `src/docker/monitoring/.env`.
2. Set a strong Grafana admin password.
3. Ensure the external `ipvlan` Docker network already exists.
4. Create host storage directories for Loki and Grafana.
5. Start the stack from `src/docker/monitoring/`.
6. Confirm Grafana loads and Alloy is pushing logs into Loki.

## Basic commands

From `src/docker/monitoring/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/monitoring/loki
mkdir -p /condolab/docker/monitoring/grafana
docker compose up -d
docker compose ps
docker compose logs -f alloy
```

## How collection works

- application containers write to stdout and stderr as normal
- Docker's default `json-file` logger stores those logs on the host
- Alloy reads container streams from the Docker socket
- Loki stores the logs
- Grafana queries Loki through a provisioned data source

Application stacks do not need their own collector sidecar for this first host.

## Default labels

The collector adds labels intended to make early queries useful:

- `job=docker`
- `container`
- `container_id`
- `compose_project`
- `compose_service`

## Access pattern

- Grafana is routed through Traefik as `https://grafana.zinkzone.tech`
- Loki stays private inside the monitoring stack network
- Alloy stays private and only needs Docker socket access

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [Infisical Compose stack](infisical-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
