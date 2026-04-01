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
2. Start the stack from `src/docker/traefik/`.
3. Confirm Traefik is healthy before attaching other app stacks.
4. Update each app stack to join the `ipvlan` network and add Traefik labels.
5. Replace the generated self-signed certificate path with a trusted certificate
   strategy when you are ready.

## Basic commands

From `src/docker/traefik/`:

```bash
docker compose up -d
docker compose ps
docker compose logs -f traefik
```

## TLS note

Traefik is configured so HTTPS is active on first boot. Without an ACME
resolver or user-supplied certificates, Traefik serves its generated
self-signed certificate. That gives encrypted transport immediately while you
decide how trusted certificates should be issued for the lab.

## App integration pattern

Each app stack should:

- join the external `ipvlan` network
- keep internal-only services on a private app network
- opt in with `traefik.enable=true`
- define a host rule that matches the intended DNS record
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
