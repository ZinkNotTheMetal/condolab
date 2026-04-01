# Ansible

Minimal bootstrap for the MS01 Debian host.

## Current scope

The bootstrap currently does these things:

1. set the timezone from variables
2. upgrade distribution packages
3. upgrade operating system packages
4. install baseline packages
5. mount configured NFS shares
6. install an optional Z-Wave udev rule
7. install the Infisical CLI on hosts that enable it
8. install Docker on hosts that enable it

## Inventory

The MS01 host is defined in `inventory/hosts.yml` under the `homelab` group.

Use `inventory/group_vars/` and `inventory/host_vars/` as the canonical variable
tree for this inventory.

Set the correct values before running:

- `ansible_host`
- `ansible_user`
- `timezone`

Docker is opt-in per host. For the MS01 host it is enabled in
`inventory/group_vars/homelab.yml`.

The Infisical CLI is also opt-in per host group. For the MS01 host it is
enabled in `inventory/group_vars/homelab.yml`.

The default package list is defined in `inventory/group_vars/homelab.yml`.

## Run

```bash
cd src/infrastructure/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/bootstrap.yml
```

## Infisical CLI after bootstrap

Point the CLI at the self-hosted instance:

```bash
infisical login --domain=https://secrets.zinkzone.tech
infisical init
```

Run `infisical init` in the working directory after login so the CLI knows
which project and environment to use there.

For non-interactive use, inject secrets into a process instead of storing them
in tracked files:

```bash
infisical run --domain=https://secrets.zinkzone.tech \
  --env=Development -- docker compose up -d
```

Use exact environment variable names for secrets, such as
`CF_DNS_API_TOKEN`, so Compose and Traefik do not need extra mapping.
