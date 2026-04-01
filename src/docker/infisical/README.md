# Infisical Docker Compose stack

Minimal self-hosted Infisical stack for the condo lab.

## Includes

- `backend` for the Infisical application
- `db` for PostgreSQL
- `redis` for cache and queueing

## Why

This is the next operational step after the MS-01 host baseline is installed and
bootstrapped. It gives the lab a single place for machine-managed secrets before
broader service rollout begins.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Replace placeholder values with generated secrets and set `SITE_URL` to the
   Infisical IPVLAN IP or hostname.
3. Start the stack:

```bash
docker compose up -d
```

1. Verify:

```bash
docker compose ps
docker compose logs -f backend
```

## Notes

- keep the real `.env` local to the target host
- protect the file with restrictive permissions
- back up the PostgreSQL data and the Infisical encryption material together
- the `backend` service joins the external `docker_ipvlan` network while `db`
  and `redis` stay on the internal app network
- ensure the `docker_ipvlan` network already exists before starting the stack
- place this behind the reverse proxy later instead of exposing it broadly
