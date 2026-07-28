#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  SUDO='sudo'
else
  SUDO=''
fi

if [[ ! -r /etc/os-release ]]; then
  echo 'Cannot detect OS version: /etc/os-release not found.' >&2
  exit 1
fi

. /etc/os-release

# Accept Ubuntu directly, and Linux Mint because it is Ubuntu-based.
case "${ID:-}" in
  ubuntu)
    ;;
  linuxmint)
    ;;
  *)
    if [[ " ${ID_LIKE:-} " != *" ubuntu "* ]]; then
      echo "This script requires Ubuntu or an Ubuntu-based distro. Detected: ${ID:-unknown}" >&2
      exit 1
    fi
    ;;
esac

# Determine the Ubuntu base version/codename used by the current distro.
UBUNTU_BASE_CODENAME="${UBUNTU_CODENAME:-}"

if [[ -z "$UBUNTU_BASE_CODENAME" && -r /etc/upstream-release/lsb-release ]]; then
  # shellcheck disable=SC1091
  . /etc/upstream-release/lsb-release
  UBUNTU_BASE_CODENAME="${DISTRIB_CODENAME:-}"
fi

if [[ -z "$UBUNTU_BASE_CODENAME" ]]; then
  echo 'Cannot determine Ubuntu base codename for this system.' >&2
  exit 1
fi

case "$UBUNTU_BASE_CODENAME" in
  focal) UBUNTU_BASE_VERSION="20.04" ;;
  jammy) UBUNTU_BASE_VERSION="22.04" ;;
  noble) UBUNTU_BASE_VERSION="24.04" ;;
  *)
    echo "Unsupported or unknown Ubuntu base codename: $UBUNTU_BASE_CODENAME" >&2
    exit 1
    ;;
esac

TMP_DEB="/tmp/packages-microsoft-prod.deb"
REPO_URL="https://packages.microsoft.com/config/ubuntu/${UBUNTU_BASE_VERSION}/packages-microsoft-prod.deb"

$SUDO apt-get update
$SUDO apt-get install -y wget apt-transport-https software-properties-common
wget -q "$REPO_URL" -O "$TMP_DEB"
$SUDO dpkg -i "$TMP_DEB"
rm -f "$TMP_DEB"
$SUDO apt-get update
$SUDO apt-get install -y powershell

echo
echo 'PowerShell installed.'
echo 'Run it with: pwsh'
echo 'Version:'
pwsh --version