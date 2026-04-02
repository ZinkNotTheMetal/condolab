# Monitoring Compose stack

This is the centralized logging and metrics step for the condo lab.

## Goal

Stand up one monitoring stack that collects Docker container logs from the host,
stores them in Loki, scrapes host and container metrics with Prometheus, and
makes both searchable in Grafana early in the lab build.

## Stack location

The stack definition lives in:

- `src/docker/monitoring/`

## Included services

- `loki` for centralized log storage
- `grafana` for dashboards and log search
- `alloy` for Docker log discovery and forwarding
- `prometheus` for metrics storage
- `node_exporter` for host metrics
- `cadvisor` for container metrics
- `dozzle` for quick live container log inspection
- `watchtower` for automatic container image updates

## Setup flow

1. Copy `src/docker/monitoring/.env.example` to
   `src/docker/monitoring/.env`.
2. Set a strong Grafana admin password.
3. Ensure the external `ipvlan` Docker network already exists.
4. Create host storage directories or ZFS datasets for Loki, Grafana, and
   Prometheus, plus Dozzle state.
5. Start the stack from `src/docker/monitoring/`.
6. Confirm Grafana loads, Alloy is pushing logs into Loki, and Prometheus is
   scraping the exporters.

## Basic commands

From `src/docker/monitoring/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/monitoring/loki
mkdir -p /condolab/docker/monitoring/grafana
mkdir -p /condolab/docker/monitoring/prometheus
mkdir -p /condolab/docker/monitoring/dozzle
chown -R 10001:10001 /condolab/docker/monitoring/loki
chown -R 472:472 /condolab/docker/monitoring/grafana
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
- Prometheus scrapes metrics from node exporter, cAdvisor, Alloy, and itself
- Grafana queries Prometheus through a provisioned data source

Application stacks do not need their own collector sidecar for this first host.

If you back these paths with ZFS datasets instead of plain directories, keep the
same mount points and apply the same ownership before the first container start.

## Default labels

The collector adds labels intended to make early queries useful:

- `job=docker`
- `container`
- `container_id`
- `compose_project`
- `compose_service`

## Metrics available

- host CPU, memory, disk, and network from `node_exporter`
- container CPU, memory, filesystem, and network from `cadvisor`
- Prometheus and Alloy self-metrics for pipeline troubleshooting

## Provisioned dashboard

Grafana auto-loads an **MS01 Overview** dashboard that includes:

- host CPU, memory, load, and uptime
- top Docker containers by CPU and memory
- warning and error log volume over time
- a logs panel you can open and inspect directly for warning and error events

## Access pattern

- Grafana is routed through Traefik as `https://grafana.zinkzone.tech`
- Dozzle is routed through Traefik as `https://dozzle.zinkzone.tech`
- Loki stays private inside the monitoring stack network
- Prometheus, Alloy, node exporter, and cAdvisor stay private inside the
  monitoring stack network
- Dozzle joins the `ipvlan` network only so operators can reach its web UI
  through Traefik while Docker socket access stays read-only
- Watchtower stays internal and checks all running containers for new images
  every 6 hours, then restarts containers when updates are available

## Update behavior

- Watchtower uses the Docker socket to monitor all running containers on the
  host
- Old images are removed after successful updates to reduce image drift and
  disk usage
- This improves patch hygiene, but it also means upstream image changes can
  restart services without a manual maintenance window

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [Infisical Compose stack](infisical-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
