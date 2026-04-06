# CloudBeaver Compose stack

This is the web database administration step for Condolab.

## Goal

Stand up one browser-based database console behind Traefik so trusted lab
clients can manage Postgres, SQL Server, and other supported engines without
switching between separate admin tools.

## Stack location

- `src/docker/cloudbeaver/`

## Included behavior

- runs CloudBeaver behind Traefik as `https://query.zinkzone.tech`
- stores the CloudBeaver workspace under `/condolab/docker/cloudbeaver/workspace`
- joins the shared `ipvlan` Docker network for Traefik routing

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Copy `src/docker/cloudbeaver/.env.example` to
   `src/docker/cloudbeaver/.env`.
3. Ensure the external `ipvlan` Docker network already exists.
4. Create the local workspace directory.
5. Start the stack from `src/docker/cloudbeaver/`.
6. Open CloudBeaver through Traefik and complete the first-run admin setup.
7. Add database connections for the internal services you want to manage.

## Basic commands

From `src/docker/cloudbeaver/`:

```bash
cp .env.example .env
mkdir -p /condolab/docker/cloudbeaver/workspace
docker compose up -d
docker compose ps
docker compose logs -f cloudbeaver
```

## Operational notes

- CloudBeaver uses a persistent workspace instead of a separate database for the
  initial homelab deployment because that keeps the stack small and easy to
  recover
- keep the route private or authenticated at the network edge because the first
  run creates the admin account in the web UI
- this stack is most useful when the lab needs one tool that can handle both
  Postgres and SQL Server

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [Monitoring Compose stack](monitoring-compose-stack.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
