# Monitoring Docker Compose stack

Centralized logging and metrics stack for the condo lab.

## Includes

- `loki` for log storage
- `grafana` for log exploration and dashboards
- `alloy` for Docker log collection and forwarding
- `prometheus` for metrics storage and queries
- `node_exporter` for host CPU, memory, filesystem, and network metrics
- `cadvisor` for container CPU, memory, filesystem, and network metrics

## Why

This stack gives the lab one place to inspect logs across Compose workloads so
early platform services can be debugged before more apps are added.

## Files

- `compose.yaml`
- `.env.example`
- `loki/config.yaml`
- `alloy/config.alloy`
- `grafana/provisioning/datasources/loki.yaml`
- `grafana/provisioning/datasources/prometheus.yaml`
- `grafana/provisioning/dashboards/monitoring.yaml`
- `grafana/dashboards/ms01-overview.json`
- `prometheus/prometheus.yml`

## Usage

1. Copy `.env.example` to `.env` and set a Grafana admin password.
2. Ensure the external Docker `ipvlan` network already exists on the host.
3. Create the host storage directories:

```bash
mkdir -p /condolab/docker/monitoring/loki
mkdir -p /condolab/docker/monitoring/grafana
mkdir -p /condolab/docker/monitoring/prometheus
chown -R 10001:10001 /condolab/docker/monitoring/loki
chown -R 472:472 /condolab/docker/monitoring/grafana
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
- Loki writes as UID `10001` and Grafana writes as UID `472`, so the backing
  directories or ZFS datasets must be owned by those users before first start
- Prometheus stores metrics under `/condolab/docker/monitoring/prometheus`
- Node exporter and cAdvisor are internal-only and scraped by Prometheus

## Collected labels

- `container`
- `container_id`
- `compose_project`
- `compose_service`
- `job=docker`

## Metrics available

- host CPU and memory via `node_exporter`
- host disk and network via `node_exporter`
- per-container CPU and memory via `cadvisor`
- per-container filesystem and network via `cadvisor`

## Grafana usage

- use **Explore → Loki** for logs, for example `{job="docker"}`
- use **Explore → Prometheus** for metrics, for example:
  - `rate(node_cpu_seconds_total{mode!="idle"}[5m])`
  - `node_memory_MemAvailable_bytes`
  - `rate(container_cpu_usage_seconds_total[5m])`
  - `container_memory_working_set_bytes`
- Grafana auto-provisions the **MS01 Overview** dashboard with host metrics,
  top container usage, and an error and warning log timeline
