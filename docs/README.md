# Docs

Primary documentation for the condo lab.

## Recommended reading order

### Host setup

- [MS-01 Debian 13 install](host-setup/ms-01-debian-13-install.md)
- [MS-01 Ansible bootstrap](host-setup/ms-01-ansible-bootstrap.md)
- [Infisical Compose stack](host-setup/infisical-compose-stack.md)
- [Traefik Compose stack](host-setup/traefik-compose-stack.md)
- [Monitoring Compose stack](host-setup/monitoring-compose-stack.md)
- [Plex Compose stack](host-setup/plex-compose-stack.md)
- [Ollama Compose stack](host-setup/ollama-compose-stack.md)
- [KaraKeep Compose stack](host-setup/karakeep-compose-stack.md)

### Standards

- [Naming conventions and standards](standards/naming-conventions.md)

### Developer information

- [Developer docs index](developer/README.md)
- [Dev container for Ansible](developer/devcontainer-ansible.md)

## Notes

- Put host runbooks and operational setup steps under `docs/host-setup/`.
- Put standards that other issues should reference under `docs/standards/`.
- Put contributor and tooling guidance under `docs/developer/`.

For the MS-01, the expected early sequence is:

1. install Debian and confirm SSH access
2. run the Ansible bootstrap
3. stand up the Traefik edge stack
4. stand up the Infisical stack for machine-managed secrets
5. stand up the monitoring stack for centralized logs
6. stand up the Plex stack for NAS-backed media playback
7. optionally stand up the Ollama experimental stack for local inference
8. optionally stand up the KaraKeep stack for bookmark capture and AI-assisted tagging
9. continue with standards and service-specific setup
