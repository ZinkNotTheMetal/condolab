# CloudBeaver Docker Compose stack

Web-based database administration stack for the condo lab.

## Includes

- CloudBeaver Community web application
- persistent workspace storage for connections and server state
- Traefik labels for the `query.zinkzone.tech` endpoint

## Why

This stack gives the lab one browser-based database console that can work across
Postgres, SQL Server, MySQL, and other engines without keeping separate
single-engine admin tools around.

## Files

- `compose.yaml`
- `.env.example`

## Usage

1. Copy `.env.example` to `.env`.
2. Ensure the external Docker `ipvlan` network already exists.
3. Create the local workspace path.
4. Start the stack.
5. Complete the first-run admin setup in the web UI.

```bash
cp .env.example .env
mkdir -p /condolab/docker/cloudbeaver/workspace
docker compose up -d
docker compose ps
docker compose logs -f cloudbeaver
```

## Service URL

- `https://query.zinkzone.tech`

## Notes

- CloudBeaver stores its persistent state in
  `/condolab/docker/cloudbeaver/workspace`
- the first login flow creates the admin account, so keep the route private
  until that setup is complete
- CloudBeaver is a better fit than pgAdmin when the lab uses more than one
  database engine
- centralized logs will flow into Loki automatically through the host collector
