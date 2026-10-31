set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

ansible_dir := "src/infrastructure/ansible"
ms01_user := "william"
ms01_pubkey := if env_var_or_default("HOME", "") == "" { "~/.ssh/id_rsa.pub" } else { env_var("HOME") + "/.ssh/id_rsa.pub" }

default:
    @just --list

# Show available recipes.
help:
    @just --list

# Confirm the local toolchain needed for this repository wrapper.
doctor:
    @command -v just >/dev/null
    @just --version
    @git --version

# Show the current source layout.
src:
    @ls "src"

# Create a docs directory if it does not exist yet.
init-docs:
    @mkdir -p "docs"

# Print a starter template for adding project-specific recipes.
template:
    @printf '%s\n' 'Add recipes here, for example:' '' 'build:' '    npm run build' '' 'test:' '    npm test'

# Print the MS01 connection host from the Ansible inventory source of truth.
ms01-host:
    @python3 -c 'from pathlib import Path; line = next(line for line in Path("{{ansible_dir}}/inventory/host_vars/ms01-01.yml").read_text().splitlines() if line.startswith("ansible_host:")); print(line.split(":", 1)[1].strip())'

# Trust the current SSH host key for MS01 before Ansible's non-interactive SSH connection.
trust-ms01-host-key:
    @mkdir -p "$HOME/.ssh"
    @chmod 700 "$HOME/.ssh"
    @touch "$HOME/.ssh/known_hosts"
    @chmod 600 "$HOME/.ssh/known_hosts"
    @host="$(just ms01-host)" && (ssh-keygen -F "$host" >/dev/null || ssh-keyscan -H "$host" >> "$HOME/.ssh/known_hosts")

# Run the bootstrap playbook for the ms01 host.
ansible-ms01: trust-ms01-host-key
    @cd {{ansible_dir}} && ANSIBLE_CONFIG=ansible.cfg ansible-galaxy collection install -r requirements.yml && ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml --limit ms01-01 --ask-become-pass

# Install a local public key for passwordless SSH to MS01.
copy-ssh-id-ms01 user=ms01_user pubkey=ms01_pubkey:
    @test -f "{{pubkey}}"
    @host="$(just ms01-host)" && ssh-copy-id -i "{{pubkey}}" "{{user}}@$host"
