# Dev container for Ansible

Use the repo dev container when you want a repeatable Ansible runner without
installing Ansible on the host machine.

## What it includes

- Ansible
- ansible-lint
- just
- OpenSSH client
- your local `~/.ssh` mounted read-only and copied into the container with
  container-safe permissions

## Open it

1. Open the repo in VS Code.
2. Choose **Reopen in Container**.
3. Wait for the post-create step to install required Ansible collections.

If you use Podman on macOS, this repo copies SSH files into the container
instead of using them in-place. That avoids permission issues with direct
bind mounts to `/home/vscode/.ssh`.

## Run Ansible for MS01

From the repo root inside the container:

```bash
just ansible-ms01
```

This installs required collections and runs the bootstrap playbook
with a limit of `ms01-01`.

## Notes

- The inventory path comes from `src/infrastructure/ansible/ansible.cfg`.
- Host key checking stays enabled, so your SSH trust must already be correct.
- Update `inventory/hosts.yml` before running if the host IP or login user changes.
