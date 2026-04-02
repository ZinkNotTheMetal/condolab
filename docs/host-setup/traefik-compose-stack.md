# Traefik Compose stack

This is the networking step that gives later Compose workloads one consistent
reverse proxy entrypoint.

## Goal

Stand up a shared Traefik edge stack with TLS enabled from the start so Pi-hole
can point friendly service names at one HTTPS endpoint on the lab network.

## Stack location

The stack definition lives in:

- `src/docker/traefik/`

## Included behavior

- listens on ports `80` and `443`
- redirects HTTP traffic to HTTPS
- enables TLS on the `websecure` entrypoint
- discovers opted-in Docker workloads only
- provides a shared `security-headers@file` middleware for routed apps
- attaches Traefik to the shared `ipvlan` network used for lab-visible access

## Setup flow

1. Ensure the shared external `ipvlan` Docker network already exists on the
   target host.
2. Create the ACME storage file on the host and lock down its permissions.
3. Store `CF_TRAEFIK_API_TOKEN` and `ACME_TRAEFIK_EMAIL` in Infisical.
4. Start the stack from `src/docker/traefik/` with `infisical run`.
5. Confirm Traefik is healthy before attaching other app stacks.
6. Update each app stack to join the `ipvlan` network and add Traefik labels.

## Basic commands

From `src/docker/traefik/`:

```bash
mkdir -p /condolab/docker/traefik/acme
touch /condolab/docker/traefik/acme/acme.json
chmod 600 /condolab/docker/traefik/acme/acme.json
infisical run --domain=https://secrets.zinkzone.tech \
  --env=Production -- docker compose up -d
docker compose ps
docker compose logs -f traefik
```

## TLS note

Traefik is configured to use Let's Encrypt through the Cloudflare DNS challenge.
Once the resolver can read `CF_TRAEFIK_API_TOKEN` and `ACME_TRAEFIK_EMAIL`, new
routers on `websecure` can obtain trusted certificates without opening the app
directly to the internet.

The resolver now lives in Traefik's static `traefik.yaml` configuration instead
of CLI flags so startup logs clearly show whether the `cloudflare` resolver was
loaded.

If you use self-hosted Infisical for secret injection, point the CLI at the
local instance before starting the stack:

```bash
infisical login --domain=https://secrets.zinkzone.tech
infisical init
```

Run `infisical init` from `src/docker/traefik/` so the CLI ties that directory
to the Traefik secret context before you use `infisical run`.

For automation, use `infisical run` with a machine identity or service token.

Store these secrets in Infisical:

- `CF_TRAEFIK_API_TOKEN` for Cloudflare DNS updates
- `ACME_TRAEFIK_EMAIL` for Let's Encrypt registration

## App integration pattern

Each app stack should:

- join the external `ipvlan` network
- keep internal-only services on a private app network
- opt in with `traefik.enable=true`
- define a host rule that matches the intended DNS record
- set `traefik.http.routers.<name>.tls.certresolver=cloudflare` when you want
  the router to request a certificate explicitly
- set `traefik.http.services.<name>.loadbalancer.server.port` when the app does
  not expose the right port automatically

## DNS and naming

- keep service hostnames aligned with the naming standard, such as
  `traefik.home.arpa` or `infisical.home.arpa`
- prefer stable DNS names over container names or host-specific addresses
- point Pi-hole records for routed apps at the Traefik `ipvlan` address

## Related docs

- [Infisical Compose stack](infisical-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
