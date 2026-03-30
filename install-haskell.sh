#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Haskell prerequisites..."
sudo apt update
sudo apt install -y \
  build-essential \
  curl \
  libffi-dev \
  libgmp-dev \
  libncurses-dev \
  pkg-config

if command -v apt-cache >/dev/null 2>&1; then
  apt-cache show libffi8ubuntu1 >/dev/null 2>&1 && sudo apt install -y libffi8ubuntu1 || true
  apt-cache show libtinfo5 >/dev/null 2>&1 && sudo apt install -y libtinfo5 || true
  apt-cache show libncurses5 >/dev/null 2>&1 && sudo apt install -y libncurses5 || true
fi

echo "==> Installing GHCup..."
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y

echo "==> Loading GHCup environment..."
if [ -f "$HOME/.ghcup/env" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.ghcup/env"
fi

echo "==> Installing recommended Haskell tools..."
ghcup install ghc recommended
ghcup set ghc recommended
ghcup install cabal recommended

echo "==> Verifying installation..."
ghc --version
cabal --version

echo
echo "Haskell is installed."
echo "If a new shell does not see ghc, run:"
echo "  source ~/.ghcup/env"