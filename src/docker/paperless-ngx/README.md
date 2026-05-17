# Paperless-ngx

Document ingestion, OCR, and archive management for Condolab.

## Purpose

Paperless-ngx is the document librarian for the future RAG workflow. It turns
scans and uploaded documents into OCR-backed, searchable archive files before AI
tools index them.

## Storage model

- local MS-01 paths hold application state, Postgres, and Redis
- Synology-backed `/mnt/Files` paths hold consume, media, and export documents
- databases stay off the NAS mount because network filesystems are a poor fit
  for database write patterns

## Setup

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
```

## RAG handoff

Use Paperless-ngx as the OCR and archive source first. A later AnythingLLM stack
should index a clean export or mirror directory rather than treating uploads to
AnythingLLM as the document system of record.
