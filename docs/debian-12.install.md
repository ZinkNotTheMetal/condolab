# Debian 13 install

Short install notes for a Debian 13 bare-metal install on the Minisforum MS-01.

## Goals

- install Debian 13 in UEFI mode
- get SSH working

## Before you start

Have these ready:

- Debian 13 amd64 ISO
- USB flash drive
- KVM access for the installer (optional)
- target hostname
- management IP plan
- SSH public key

## Create the installer USB on macOS

Recommended:

- Balena Etcher

Other workable options:

- Raspberry Pi Imager
- `dd` from terminal if you already use it safely

With Balena Etcher:

1. Download the Debian 13 ISO.
2. Open Balena Etcher.
3. Select the ISO.
4. Select the USB drive.
5. Flash the drive.

## BIOS and boot

Before installing:

1. Confirm the MS-01 is booting in UEFI mode.
2. Make sure the target NVMe drive is visible.
3. Boot from the USB installer.
4. If Secure Boot causes trouble, disable it temporarily.

## Debian install choices

Use these defaults unless you have a reason not to:

- installer: standard Debian installer
- network: connect your 10Gb interface you plan to use
- hostname: set the final host name now
- user: create your admin user
- partitioning: guided, use entire disk, ext4
- packages: SSH server + standard system utilities only
- desktop environment: none
- boot loader: install GRUB in UEFI mode

Keep the install small. Do not install extra services yet.

## First boot

After reboot, log in as `root` or use the installer-created admin account.

If the install was done from removable media, confirm APT has online Debian
repositories configured before trying to install packages.

Expected Debian 13 (`trixie`) sources:

```bash
cat >/etc/apt/sources.list <<'EOF'
deb http://deb.debian.org/debian trixie main contrib non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free-firmware
EOF
```

Then update the package index and install the baseline tools Ansible expects:

```bash
apt update
apt full-upgrade -y
apt install -y sudo curl git vim ca-certificates python3
```

If your login user is not already in `sudo`, add it before continuing:

```bash
usermod -aG sudo <login-user>
```

For this host, the expected command is:

```bash
usermod -aG sudo william
```

Log out and back in so the new group membership applies.

Then confirm:

```bash
hostnamectl
ip addr
ip route
sudo systemctl status ssh
```

## Get the host ready for Ansible

Complete these steps before running playbooks:

1. Confirm the intended 10Gb interface has link.
2. Set the final IP configuration.
3. Add your SSH public key to the login account you will use for Ansible.
4. Confirm that account is in the `sudo` group.
5. Confirm you can SSH to the host.

Quick check from your workstation:

```bash
ssh <login-user>@<host-ip>
sudo -v
python3 --version
```

When those pass, the machine is ready for the Ansible bootstrap in this repo.

## References

- Debian 13 installer documentation
- Minisforum MS-01 hardware specifications
