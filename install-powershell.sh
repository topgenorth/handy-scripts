#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  SUDO='sudo'
else
  SUDO=''
fi

if [[ ! -r /etc/os-release ]]; then
  echo 'Cannot detect Linux distribution: /etc/os-release not found.' >&2
  exit 1
fi

. /etc/os-release

DISTRO_ID="${ID:-}"
VERSION="${VERSION_ID:-}"
UBUNTU_BASE_VERSION="${UBUNTU_CODENAME:-}"
REPO_VERSION=""

case "$DISTRO_ID" in
  ubuntu)
    if [[ -z "$VERSION" ]]; then
      echo 'Cannot detect Ubuntu VERSION_ID.' >&2
      exit 1
    fi
    REPO_VERSION="$VERSION"
    ;;
  linuxmint)
    REPO_VERSION="${UBUNTU_CODENAME:-}"
    case "${UBUNTU_CODENAME:-}" in
      noble) REPO_VERSION="24.04" ;;
      jammy) REPO_VERSION="22.04" ;;
      focal) REPO_VERSION="20.04" ;;
      *)
        echo "Unsupported or unknown Linux Mint base Ubuntu codename: ${UBUNTU_CODENAME:-unknown}" >&2
        echo 'Supported Ubuntu bases for this script: focal, jammy, noble.' >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "This script is intended for Ubuntu or Linux Mint. Detected: ${DISTRO_ID:-unknown}" >&2
    exit 1
    ;;
esac

TMP_DEB="/tmp/packages-microsoft-prod.deb"
REPO_URL="https://packages.microsoft.com/config/ubuntu/${REPO_VERSION}/packages-microsoft-prod.deb"

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
