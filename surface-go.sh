# I used this when I repaved a 2018 Surface Go with Ubuntu  24.04

sudo rm -f /usr/share/keyrings/linux-surface.gpg
sudo rm -f /etc/apt/keyrings/linux-surface.gpg
sudo rm -f /etc/apt/trusted.gpg.d/linux-surface.gpg
sudo rm -f /etc/apt/sources.list.d/linux-surface*.list
sudo apt update  # Clear errors

# sudo rm -f /usr/share/keyrings/linux-surface.gpg
# sudo rm -f /etc/apt/sources.list.d/linux-surface.list
# curl -fLO https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc
# gpg --show-keys surface.asc # Verify it shows key info (not empty/error)
# gpg --dearmor surface.asc | sudo tee /usr/share/keyrings/linux-surface.gpg > /dev/null#echo "deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface.gpg] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list
# rm surface.asc
# curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/extrepo.sh | sh
# sudo extrepo install linux-surface
#sudo aptitude update
#sudo aptitude install linux-surface linux-headers-surface iptsd libwacom-surface



wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/linux-surface.gpg

echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" \
	| sudo tee /etc/apt/sources.list.d/linux-surface.list

sudo apt install linux-image-surface linux-headers-surface libwacom-surface iptsd    

#sudo apt install libcamera0.2 gstreamer1.0-libcamera libcamera-ipa pipewire-libcamera libcamera-tools linux-firmware
#sudo usermod -aG video $USER
#newgrp video

