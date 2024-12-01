#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

#
#Install Docker
#

#Remove previous versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER

#
#Install Chrome
#
curl -O -z google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y

#
#Install Hailo Driver 
#
sudo apt-get install build-essential dkms -y 
curl -O -z hailort-pcie-driver_4.19.0_all.deb https://storage.googleapis.com/deepperception_public/hailort-pcie-driver_4.19.0_all.deb
yes | sudo dpkg -i hailort-pcie-driver_4.19.0_all.deb

#
#Install Misc Packages
#
sudo apt-get install nmap net-tools openssh-server vim -y

sudo ./increase_fd_limits.sh

echo -e "\n\nReboot Needed to Complete Hailo Driver Install!!!\n\n"
