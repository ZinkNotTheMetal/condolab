# Monitoring Docker Compose stack

Centralized logging stack for the condo lab.

## Includes

- `loki` for log storage
- `grafana` for log exploration and dashboards
- `alloy` for Docker log collection and forwarding

## Why

This stack gives the lab one place to inspect logs across Compose workloads so
early platform services can be debugged before more apps are added.

## Files

- `compose.yaml`
- `.env.example`
- `loki/config.yaml`
- `alloy/config.alloy`
- `grafana/provisioning/datasources/loki.yaml`

## Usage

1. Copy `.env.example` to `.env` and set a Grafana admin password.
2. Ensure the external Docker `ipvlan` network already exists on the host.
3. Create the host storage directories:

```bash
mkdir -p /condolab/docker/monitoring/loki
mkdir -p /condolab/docker/monitoring/grafana
```

1. Start the stack:

```bash
docker compose up -d
```

1. Verify:

```bash
docker compose ps
docker compose logs -f alloy
```

## Notes

- application containers do not write to `/var/lib/docker` directly; Docker's
  default `json-file` logging driver writes container stdout and stderr on the
  host and Alloy reads Docker logs through the Docker socket
- this stack uses one central collector for the host, not one collector per app
  stack
- Grafana is routed through Traefik as `https://grafana.zinkzone.tech`
- Loki remains internal to the monitoring stack

## Collected labels

- `container`
- `container_id`
- `compose_project`
- `compose_service`
- `job=docker`
