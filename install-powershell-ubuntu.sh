#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  SUDO='sudo'
else
  SUDO=''
fi

if [[ ! -r /etc/os-release ]]; then
  echo 'Cannot detect Ubuntu version: /etc/os-release not found.' >&2
  exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "This script is intended for Ubuntu. Detected: ${ID:-unknown}" >&2
  exit 1
fi

if [[ -z "${VERSION_ID:-}" ]]; then
  echo 'Cannot detect Ubuntu VERSION_ID.' >&2
  exit 1
fi

TMP_DEB="/tmp/packages-microsoft-prod.deb"
REPO_URL="https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb"

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