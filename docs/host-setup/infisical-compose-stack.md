# Infisical Compose stack

This is the next step after the MS-01 Debian install and Ansible bootstrap.

## Goal

Stand up a small self-hosted Infisical deployment so machine-managed secrets can
move out of scattered local `.env` files and into one managed platform.

## Stack location

The stack definition lives in:

- `docker/infisical/`

## Included services

- `backend` for Infisical
- `db` for PostgreSQL
- `redis` for Redis

## Setup flow

1. Review the stack files in `docker/infisical/`.
2. Copy `docker/infisical/.env.example` to `docker/infisical/.env`.
3. Replace placeholder values with generated secrets and set `SITE_URL` to the
   Infisical IPVLAN IP or hostname.
4. Start the stack from that directory.
5. Verify the UI responds locally before putting it behind a reverse proxy.

## Basic commands

From `docker/infisical/`:

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
- do not publish host ports for `backend` when using IPVLAN; reach it by its
  assigned IPVLAN IP instead

## Notes

- do not commit the real `.env`
- keep the Infisical encryption and auth secrets backed up outside the stack
- back up PostgreSQL data before upgrades or major changes
- ensure the router/LAN has the required route for the IPVLAN subnet back to the
  Docker host
- add TLS and reverse proxy routing in a later networking step

## Related docs

- [MS-01 Debian 13 install](ms-01-debian-13-install.md)
- [MS-01 Ansible bootstrap](ms-01-ansible-bootstrap.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
