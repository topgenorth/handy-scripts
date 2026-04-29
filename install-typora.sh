#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root: sudo $0"
  exit 1
fi
export DEBIAN_FRONTEND=noninteractive

sudo apt update
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
echo 'deb https://typora.io/linux ./' | sudo tee /etc/apt/sources.list.d/typora.list
sudo apt update
sudo apt install typora