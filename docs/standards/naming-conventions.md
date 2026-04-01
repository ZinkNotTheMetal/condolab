# Naming conventions and standards

Baseline naming guidance for condo lab infrastructure, services, files, and
documentation.

## Why

Consistent naming reduces drift, makes troubleshooting faster, and gives later
infrastructure issues a stable base to build on.

## Principles

- prefer descriptive names over abbreviations
- use lowercase words with hyphen separators for human-facing names
- use predictable prefixes when the object needs environmental context
- avoid one-off names that encode temporary implementation details
- choose names that remain valid if the service moves hosts later

## Host and node names

- use short, descriptive hostnames
- use numeric suffixes only when the role may scale beyond one node
- avoid embedding operating system or temporary hardware details in the name

Examples:

- `ms01`
- `app01`
- `nas01`

Avoid:

- `minisforum-box`
- `docker-server`
- `newhost`

## Docker Compose project names

- use lowercase hyphenated names
- separate project by function denoted by underscore `{project}_{service}`
- keep project names stable even if the implementation changes internally
- treat the project name as the stack or deployment boundary

Examples:

- `core_traefik`
- `media_jellyfin`
- `smart-home_home-assistant`
- `utility_uptime-kuma`

## Container names

- prefer the Compose-managed naming unless a fixed name is required
- if a fixed name is required, use `{project}_{service}_{purpose}`
- do not use personal initials or temporary migration labels

This keeps the deployment boundary and the service role easy to scan at a
glance.

Examples:

- `core_traefik_api`
- `media_jellyfin_ui`
- `utility_postgres_worker`

Example pattern:

- project: `core-traefik`
- service: `traefik`
- purpose/container: `worker`

## Storage paths and service directories

- use stable top-level paths tied to purpose, not implementation history
- use one directory per service under the relevant area
- keep service directory names aligned with stack and service names

Recommended examples:

- `/condolab/stacks/core/traefik`
- `/condolab/stacks/media/jellyfin`
- `/condolab/stacks/home/home-assistant`
- `/condolab/databases/postgres`
- `/condolab/backups/postgres`

## Networks, VLANs, and subnets

- name networks by purpose, not by the first service that used them
- keep VLAN names short and descriptive
- document subnet ownership with the same logical names used elsewhere

Examples:

- `management`
- `server`
- `iot`
- `guest`

## DNS records and service URLs

- use lowercase DNS names only
- keep service hostnames aligned with the service name users recognize
- prefer stable hostnames that do not expose backend implementation details

Examples:

- `traefik.home.arpa`
- `grafana.home.arpa`
- `jellyfin.home.arpa`
- `ha.home.arpa`

If a service is environment-specific, prefix the environment or location only
when it adds real clarity.

## Backup artifact names

- include service name, artifact type, and timestamp
- use UTC timestamps in sortable format
- avoid spaces in file names

Examples:

- `postgres_dump_2026-04-01T120000Z.sql.gz`
- `home-assistant_backup_2026-04-01T120000Z.tar`
- `condolab_restic_2026-04-01T120000Z.log`

## Repository naming

### Docs

- use lowercase kebab-case file names
- name files by topic, not by date unless the date is the point
- group by purpose under `docs/host-setup/`, `docs/standards/`, and
  `docs/developer/`

Examples:

- `docs/host-setup/ms-01-debian-13-install.md`
- `docs/standards/naming-conventions.md`
- `docs/developer/devcontainer-ansible.md`

### Infrastructure folders

- use technology-first grouping under `src/infrastructure/`
- use workload or platform names under each technology folder
- keep folder names aligned with the same terms used in docs and automation

Examples:

- `src/infrastructure/terraform/`
- `src/infrastructure/ansible/`
- `src/infrastructure/containers/`

## Secret files and templates

- use `.example` files for committed templates
- do not commit live secrets
- name secret files by service and scope

Examples:

- `.env.example`
- `infisical.example.env`
- `traefik.dns.example.env`

Avoid:

- `real.env`
- `stuff.env`
- `temp-secrets.txt`

## Labels and metadata

Use labels and metadata to explain ownership and intent rather than
implementation trivia.

Examples:

- `managed-by=terraform`
- `service=grafana`
- `stack=monitoring`
- `owner=platform`

## Anti-patterns to avoid

- ambiguous abbreviations that only make sense right now
- inconsistent separators for the same object type
- host-specific naming for services that may later move elsewhere
- naming by migration phase, such as `new-`, `old-`, or `temp-`
- folder names that hide purpose, such as `misc`, `other`, or `test2`

## How follow-on issues should use this

- issue #33 should align storage paths with these names
- issue #37 should align Compose project and stack names with these names
- issue #35 should align backup artifact naming with these names
- issue #23 should align DNS and service URL naming with these names
