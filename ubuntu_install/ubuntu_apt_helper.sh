#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run with 'sudo'"
    exit 1
fi

apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install -y docker-buildx-plugin docker-ce-cli docker-ce npm pkg-config libncurses-dev libgmp-dev liblzma-dev libffi-dev libxmlsec1-dev libxml2-dev tk-dev xz-utils libncurses-dev libsqlite3-dev libreadline-dev libbz2-dev zlib1g-dev libssl-dev build-essential curl git
