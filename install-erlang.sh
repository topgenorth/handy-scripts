#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y erlang elixir

echo
echo "Installed versions:"
erl -eval 'io:format("Erlang/OTP ~s~n", [erlang:system_info(otp_release)]), halt().' -noshell
elixir --version