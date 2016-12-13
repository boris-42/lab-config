#!/bin/bash -e

cwd="$(dirname $0)/.."
codename="$(lsb_release --short --codename)"
username="$(id --user --name)"

# Configure host parameters
cat "$cwd/scripts/files/sysctl.conf" | sudo tee /etc/sysctl.d/60-oss_lab.conf
sudo sysctl --system

# Install docker
sudo apt-get update \
    && sudo apt-get install --yes \
        apt-transport-https \
        ca-certificates \
        python-virtualenv \
        python-pip
sudo apt-key adv \
    --keyserver hkp://ha.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-${codename} main" \
    | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update \
    && sudo apt-get install --yes docker-engine
sudo usermod -aG docker $username

# Install docker-compose in virtualenv
$cwd/scripts/install.sh
