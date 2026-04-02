#!/bin/bash
# Not to sure how well this works?

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${GREEN}Installing JetBrains Toolbox on Linux Mint 22.3...${NC}"

sudo apt update && sudo apt install -y libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar libfuse2 dbus-user-session

# Download to temp
TEMP=$(mktemp -d)
cd "$TEMP"
wget -qO toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"

# Install to /opt
sudo mkdir -p /opt
sudo tar -xf toolbox.tar.gz -C /opt --no-same-owner --no-same-permissions

rm toolbox.tar.gz
cd - && rm -rf "$TEMP"

# Launch (creates ~/.local/share config/desktop)
sudo chown -R $USER:$USER /opt/jetbrains-toolbox-*
/opt/jetbrains-toolbox-*/bin/jetbrains-toolbox &

echo -e "${GREEN}Success! Runs from /opt/jetbrains-toolbox-*/bin/jetbrains-toolbox${NC}"
echo "Desktop entry created after first login/close."
