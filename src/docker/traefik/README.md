# Traefik Docker Compose stack

Minimal edge proxy stack for the condo lab.

## Includes

- `traefik` for Docker-native reverse proxying
- TLS-enabled `websecure` entrypoint on port `443`
- automatic HTTP to HTTPS redirect on port `80`
- Cloudflare-backed Let's Encrypt DNS challenge support
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
2. Create the ACME storage file on the host.
3. Start the stack with Infisical-provided secrets:

```bash
mkdir -p /condolab/docker/traefik/acme
touch /condolab/docker/traefik/acme/acme.json
chmod 600 /condolab/docker/traefik/acme/acme.json
infisical run --domain=https://secrets.zinkzone.tech \
  --env=Production -- docker compose up -d
```

1. Verify:

```bash
docker compose ps
docker compose logs -f traefik
```

## Notes

- Traefik starts with TLS enabled immediately. Until you add a trusted
  certificate source, browsers may briefly see the default certificate until
  Let's Encrypt finishes the DNS challenge and stores the issued certificate.
- `exposedByDefault: false` keeps unrelated containers private until you opt
  them in with labels.
- The Docker socket is mounted read-only because Traefik needs discovery, not
  container control.
- Traefik is attached directly to the shared `ipvlan` network so Pi-hole can
  point friendly names at the Traefik LAN IP.
- Traefik maps the Infisical secret `CF_TRAEFIK_API_TOKEN` into the Cloudflare
  environment variable the ACME provider expects.
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
  - traefik.http.routers.app.tls.certresolver=cloudflare
  - traefik.http.routers.app.middlewares=security-headers@file
  - traefik.http.services.app.loadbalancer.server.port=3000
```
