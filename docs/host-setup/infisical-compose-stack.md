# Infisical Compose stack

This is the application step after the MS-01 Debian install, Ansible bootstrap,
and Traefik edge stack are in place.

## Goal

Stand up a small self-hosted Infisical deployment so machine-managed secrets can
move out of scattered local `.env` files and into one managed platform.

## Stack location

The stack definition lives in:

- `src/docker/infisical/`

## Included services

- `backend` for Infisical
- `db` for PostgreSQL
- `redis` for Redis

## Setup flow

1. Review the stack files in `src/docker/infisical/`.
2. Copy `src/docker/infisical/.env.example` to `src/docker/infisical/.env`.
3. Replace placeholder values with generated secrets and set `SITE_URL` to
   `https://infisical.home.arpa` or the final routed hostname you choose.
4. If this is a fresh Postgres 18 deployment, remove any old database files from
    `/condolab/databases/infisical/postgres` before the first start.
5. Ensure the external `ipvlan` Docker network already exists.
6. Start the stack from that directory.
7. Verify the app responds through Traefik on the routed HTTPS hostname.

## Basic commands

From `src/docker/infisical/`:

```bash
cp .env.example .env
chmod 600 .env
docker compose up -d
docker compose ps
docker compose logs -f backend
```

## Networking

- `backend` joins the external `docker_ipvlan` network created by Ansible
- `db` and `redis` remain on an internal Compose network so they are not exposed
  on the LAN
- do not publish host ports for `backend`; Traefik terminates TLS and forwards
  traffic over the shared `ipvlan` network

## Notes

- do not commit the real `.env`
- keep the Infisical encryption and auth secrets backed up outside the stack
- back up PostgreSQL data before upgrades or major changes
- the Postgres 18 container expects the host mount at `/var/lib/postgresql`
- ensure the external `ipvlan` Docker network exists before first start
- the default stack labels route Infisical as `https://infisical.home.arpa`
- if Pi-hole or another DNS server is used, point the chosen hostname at the
  Traefik `ipvlan` IP rather than the container IP

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [MS-01 Debian 13 install](ms-01-debian-13-install.md)
- [MS-01 Ansible bootstrap](ms-01-ansible-bootstrap.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
