# MS-01 Ansible bootstrap

Run this after the base Debian install is complete and SSH access is working.

## Why

The Debian installer gets the host online. The Ansible bootstrap makes the host
consistent with the repo baseline so later storage, Docker Compose, and service
setup steps start from a predictable state.

## When to run it

Run this after:

1. Debian is installed on the MS-01.
2. The host has a stable hostname and management IP.
3. SSH access works from your workstation.
4. The target login account has `sudo` access.

Start with the install guide if that work is not done yet:

- [MS-01 Debian 13 install](ms-01-debian-13-install.md)

## What the bootstrap currently configures

The current bootstrap playbook is intentionally small. It currently:

1. sets the timezone from inventory variables
2. upgrades distribution packages
3. upgrades operating system packages
4. installs baseline packages
5. mounts configured NFS shares
6. installs an optional Z-Wave udev rule
7. installs Docker on hosts that enable it

This gives the host a clean baseline without trying to solve all application
deployment concerns at once.

## Source of truth

The automation lives under:

- `src/infrastructure/ansible/`

The current bootstrap playbook is:

- `src/infrastructure/ansible/playbooks/bootstrap.yml`

The inventory source of truth is:

- `src/infrastructure/ansible/inventory/hosts.yml`
- `src/infrastructure/ansible/inventory/group_vars/`
- `src/infrastructure/ansible/inventory/host_vars/`

## Values to review before running

Confirm these values match the real host:

- `ansible_host`
- `ansible_user`
- `timezone`

Also review:

- whether Docker should be enabled for the host
- whether any NFS mounts should be present yet
- whether the optional Z-Wave rule is needed

For the current repo, Docker defaults are managed in:

- `src/infrastructure/ansible/inventory/group_vars/homelab.yml`

## How to run it

### Option 1: use the dev container

This is the preferred option when you want a repeatable local runner.

1. Open the repo in VS Code.
2. Reopen the repo in the dev container.
3. From the repo root, run:

```bash
just ansible-ms01
```

See also:

- [Dev container for Ansible](../developer/devcontainer-ansible.md)

### Option 2: run Ansible directly

From the repository root:

```bash
cd src/infrastructure/ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/bootstrap.yml
```

## Pre-flight checks

Before running the playbook, confirm:

```bash
ssh <login-user>@<host-ip>
sudo -v
python3 --version
```

If those pass, the host is usually ready for the bootstrap.

## Expected result

After the run:

- the host timezone should match inventory
- baseline packages should be installed
- configured package updates should be applied
- optional NFS mounts should be present if enabled
- Docker should be installed if enabled for the host

## Validation after the run

Use these checks from the host as needed:

```bash
hostnamectl
timedatectl
docker --version
mount | grep nfs
systemctl status docker
```

Run only the checks that apply to the features enabled for the host.

## Troubleshooting

### SSH or sudo failures

If the playbook cannot connect or escalate privileges, re-check:

- `ansible_host`
- `ansible_user`
- SSH key trust
- `sudo` membership on the target account

### Python missing on target host

The Debian install guide includes `python3` because Ansible expects it on the
target host.

### Docker not installed

Check whether Docker is enabled for the host in group or host variables before
assuming the playbook failed.

### NFS mounts missing

Check whether the NFS shares are defined and whether the target NAS is reachable
from the host.

## Related docs

- [MS-01 Debian 13 install](ms-01-debian-13-install.md)
- [Ansible implementation README](../../src/infrastructure/ansible/README.md)
- [Dev container for Ansible](../developer/devcontainer-ansible.md)
