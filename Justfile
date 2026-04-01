set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

ansible_dir := "src/infrastructure/ansible"
ms01_host := "192.168.0.8"
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

# Run the bootstrap playbook for the ms01 host.
ansible-ms01:
    @cd {{ansible_dir}} && ANSIBLE_CONFIG=ansible.cfg ansible-galaxy collection install -r requirements.yml && ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory/hosts.yml playbooks/bootstrap.yml --limit ms01-01 --ask-become-pass

# Install a local public key for passwordless SSH to MS01.
copy-ssh-id-ms01 user=ms01_user host=ms01_host pubkey=ms01_pubkey:
    @test -f "{{pubkey}}"
    @ssh-copy-id -i "{{pubkey}}" "{{user}}@{{host}}"
