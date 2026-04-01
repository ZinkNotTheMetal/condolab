FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install the local automation toolchain so Ansible can run from inside the
# development container without extra workstation setup.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        just \
        openssh-client \
        python3-pip \
        sshpass \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        'ansible==13.5.0' \
        'ansible-lint==26.3.0' \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
