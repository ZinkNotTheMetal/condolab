# Paperless-ngx Compose stack

This is the document ingestion and OCR layer for Condolab.

## Goal

Stand up Paperless-ngx on the MS-01 while using the Synology NAS for durable
document storage. This prepares documents for later RAG indexing without making
AnythingLLM responsible for OCR or archive management.

## Stack location

- `src/docker/paperless-ngx/`

## Included behavior

- runs Paperless-ngx behind Traefik as `https://paperless.zinkzone.tech`
- uses Postgres and Redis on local MS-01 storage
- uses Tika and Gotenberg for richer Office/document extraction
- consumes documents from the Synology-backed `/mnt/Files` mount
- stores archived document media on the Synology-backed `/mnt/Files` mount
- keeps database files under `/condolab/databases/paperless-ngx/postgres`

## NAS mount layout

The current Ansible inventory mounts Synology `/volume1/Files` at `/mnt/Files`.
Use that mount for Paperless document data:

```text
/mnt/Files/condolab/documents/paperless/consume
/mnt/Files/condolab/documents/paperless/media
/mnt/Files/condolab/documents/paperless/export
```

Keep these paths local to the MS-01:

```text
/condolab/docker/paperless-ngx/data
/condolab/docker/paperless-ngx/redis
/condolab/databases/paperless-ngx/postgres
```

## Setup flow

1. Confirm the Traefik stack is healthy.
2. Confirm the external `ipvlan` Docker network already exists.
3. Confirm `/mnt/Files` is mounted from Synology.
4. Copy `src/docker/paperless-ngx/.env.example` to `src/docker/paperless-ngx/.env`.
5. Generate the required secrets and set the final routed hostname if needed.
6. Create the local and NAS-backed storage directories.
7. Start the stack from `src/docker/paperless-ngx/`.
8. Upload a small scanned PDF to the consume folder and confirm OCR completes.

## Basic commands

From `src/docker/paperless-ngx/`:

```bash
cp .env.example .env
chmod 600 .env
mkdir -p /condolab/docker/paperless-ngx/data
mkdir -p /condolab/docker/paperless-ngx/redis
mkdir -p /condolab/databases/paperless-ngx/postgres
mkdir -p /mnt/Files/condolab/documents/paperless/consume
mkdir -p /mnt/Files/condolab/documents/paperless/media
mkdir -p /mnt/Files/condolab/documents/paperless/export
docker compose up -d
docker compose ps
docker compose logs -f webserver
```

## OCR notes

- `PAPERLESS_OCR_MODE=skip` avoids reprocessing PDFs that already contain text.
- `PAPERLESS_TASK_WORKERS=1` and `PAPERLESS_THREADS_PER_WORKER=1` keep CPU use
  predictable on the MS-01.
- Add more OCR languages only when needed because each language increases OCR
  work and can reduce accuracy on mixed documents.

## RAG notes

Paperless-ngx should be the source of truth for OCR and document organization.
AnythingLLM should index an export or mirror of the Paperless archive later so
RAG has clean text-backed documents to retrieve from.

## Related docs

- [Traefik Compose stack](traefik-compose-stack.md)
- [MS-01 Ansible bootstrap](ms-01-ansible-bootstrap.md)
- [Naming conventions and standards](../standards/naming-conventions.md)
