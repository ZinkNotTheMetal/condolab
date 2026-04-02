# Condolab

Infrastructure notes, standards, and automation for the condo lab.

## Start here

Use these docs in order when bringing up or extending the environment:

1. [Docs index](docs/README.md)
2. [MS-01 Debian install and ZFS prerequisites](docs/host-setup/ms-01-debian-13-install.md)
3. [MS-01 Ansible bootstrap](docs/host-setup/ms-01-ansible-bootstrap.md)
4. [Traefik Compose stack](docs/host-setup/traefik-compose-stack.md)
5. [Infisical Compose stack](docs/host-setup/infisical-compose-stack.md)
6. [Monitoring Compose stack](docs/host-setup/monitoring-compose-stack.md)
7. [Naming conventions and standards](docs/standards/naming-conventions.md)
8. [Developer documentation](docs/developer/README.md)

## Current focus

- establish the MS-01 host baseline
- standardize naming before broader service deployment
- keep infrastructure decisions documented before implementation expands

## Related areas

- Ansible bootstrap: [`src/infrastructure/ansible/README.md`](src/infrastructure/ansible/README.md)
- Documentation index: [`docs/README.md`](docs/README.md)
