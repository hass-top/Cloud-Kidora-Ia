#!/usr/bin/env bash
# =============================================================================
#  wsl-bootstrap.sh — set up Ansible inside WSL (Debian) as the control node
# =============================================================================
#  Why this exists
#  ---------------
#  Ansible does not support a Windows control node. ansible-core imports POSIX
#  modules at CLI start-up, and on Windows those are absent:
#
#      ansible/utils/display.py            import fcntl, termios
#      ansible/plugins/connection/ssh.py   import fcntl, pty
#      ansible/parsing/vault/__init__.py   import fcntl
#      ansible/_internal/_locking.py       import fcntl
#
#  There is a second, earlier failure too: check_blocking_io() calls
#  os.get_blocking() on stdin/stdout/stderr, which raises
#  "OSError: [WinError 1] Incorrect function" for a Windows console handle,
#  before Ansible does any work at all.
#
#  Windows is supported as a *managed node*, not as a controller. WSL gives us
#  a real Linux userland, where all of the above just works.
#
#  Usage (from the ansible/ directory, in PowerShell):
#      wsl -d Debian -- bash /mnt/c/.../ansible/scripts/wsl-bootstrap.sh
#
#  Or simply:  .\scripts\wsl-ansible.ps1 install
# =============================================================================
set -euo pipefail

# The Windows PATH is appended to the Linux one by WSL, and the Windows pyenv
# shims come out as /mnt/c/.../python3 - a Windows binary that Linux cannot
# execute. Resetting PATH to the Linux locations avoids the confusing
# "cannot execute: required file not found".
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

VENV="${KIDORA_VENV:-$HOME/.venvs/kidora-ansible}"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# --- System packages ----------------------------------------------------------
# This runs FIRST. A minimal Debian 13 WSL ships without python3 at all, so the
# version check would fail before anything could be installed.
log "Installing system packages"
if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get not found. This script targets Debian/Ubuntu WSL." >&2
    exit 1
fi
# DEBIAN_FRONTEND=noninteractive so an unattended run cannot stop on a prompt.
SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"
$SUDO apt-get update -qq
# python3-venv is a separate package on Debian; without it `python3 -m venv`
# fails with "ensurepip is not available". --no-install-recommends keeps the
# install small and avoids pulling in a desktop stack.
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    --no-install-recommends \
    python3 python3-venv python3-pip openssh-client ca-certificates git

log "Environment"
python3 --version
sed -n 's/^PRETTY_NAME=//p' /etc/os-release

log "Creating the virtualenv at $VENV"
mkdir -p "$(dirname "$VENV")"
python3 -m venv "$VENV"
PY="$VENV/bin/python"
"$PY" -m pip install --quiet --upgrade pip

log "Installing ansible-core"
# ansible-core rather than the full `ansible` package: this project is a
# set of playbooks, not a collection of content, and the meta package is 51 MB
# of collections we would never use.
"$PY" -m pip install --quiet 'ansible-core>=2.16,<2.22'

log "Installing the collections from requirements.yml"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$HERE")"
"$VENV/bin/ansible-galaxy" collection install -r "$ANSIBLE_DIR/requirements.yml" --force

log "Verifying"
"$VENV/bin/ansible" --version | head -2
"$VENV/bin/ansible-galaxy" collection list | grep -E 'community\.(docker|general)|ansible\.posix'

cat <<EOF

=============================================================================
Ansible is ready in WSL.

Run the playbooks with:
    wsl -d Debian -- bash -c "cd $ANSIBLE_DIR && .venv-wsl/bin/ansible-playbook ..."

or simply:
    .\\scripts\\wsl-ansible.ps1 run -- --syntax-check -i inventories/staging/hosts.ini playbooks/staging/main.yml

SSH keys: WSL has its own ~/.ssh. Copy yours across, or point at the Windows one:
    cp /mnt/c/Users/$USER/.ssh/kidora_ssh ~/.ssh/ && chmod 600 ~/.ssh/kidora_ssh
=============================================================================
EOF
