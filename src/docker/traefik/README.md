# Traefik Docker Compose stack

Minimal edge proxy stack for the condo lab.

## Includes

- `traefik` for Docker-native reverse proxying
- TLS-enabled `websecure` entrypoint on port `443`
- automatic HTTP to HTTPS redirect on port `80`
- file-provider middleware for shared security headers

## Why

This stack creates one stable ingress point for later Compose workloads so each
service can publish itself with labels instead of bespoke proxy files.

## Files

- `compose.yaml`
- `traefik.yaml`
- `config/dynamic/security.yaml`

## Usage

1. Ensure the external Docker `ipvlan` network already exists on the target host.
2. Start the stack:

```bash
docker compose up -d
```

1. Verify:

```bash
docker compose ps
docker compose logs -f traefik
```

## Notes

- Traefik starts with TLS enabled immediately. Until you add a trusted
  certificate source, browsers will see Traefik's generated self-signed
  certificate.
- `exposedByDefault: false` keeps unrelated containers private until you opt
  them in with labels.
- The Docker socket is mounted read-only because Traefik needs discovery, not
  container control.
- Traefik is attached directly to the shared `ipvlan` network so Pi-hole can
  point friendly names at the Traefik LAN IP.
- Future app stacks should join the external `ipvlan` network and set
  `traefik.enable=true` plus the matching router labels.

## Example app labels

```yaml
labels:
  - traefik.enable=true
  - traefik.docker.network=ipvlan
  - traefik.http.routers.app.rule=Host(`app.home.arpa`)
  - traefik.http.routers.app.entrypoints=websecure
  - traefik.http.routers.app.tls=true
  - traefik.http.routers.app.middlewares=security-headers@file
  - traefik.http.services.app.loadbalancer.server.port=3000
```
