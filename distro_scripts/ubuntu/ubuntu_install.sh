#!/bin/bash

set -e

if [[ "$EUID" -eq 0 ]]; then
    echo "This script should not be run as root. Please run without sudo"
    exit 1
fi

# Pre-check apt packages, since we aren't going to install them here (no sudo)
ALL_PKGS="$(apt list --installed 2>/dev/null)"

REQUIRED="git curl gcc build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libffi8 libgmp-dev libgmp10 libncurses-dev pkg-config npm docker-ce docker-ce-cli docker-buildx-plugin"

MISSING=""

for REQ in $REQUIRED; do
    if ! echo "$ALL_PKGS" | grep "$REQ" >/dev/null; then
        MISSING="$REQ $MISSING"
    fi
done

if [[ ! -z "$MISSING" ]]; then
    echo -e "The following required packages are missing:\n $MISSING"
    echo -e "\nPlease install them using apt\n"
    echo -e "NOTE: Docker packages must be installed from docker's apt repository\nSee https://docs.docker.com/engine/install/ubuntu/, section 'Install using the apt repository'"
    exit 1
fi

if ! which python || ! python --version | grep "3.11"; then
    echo "Rottnest requires that 'python' on PATH is python 3.11. Please configure your python environment such that the correct version is available under the name 'python'"
    exit 1
fi

echo "Installing rottnest prerequisites that aren't provided by apt"
echo "You may see warnings about reinstallations. These should be fine"

# rustup
if ! which rustc || ! which cargo; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup
    chmod u+x /tmp/rustup
    /tmp/rustup -y
fi
source ~/.cargo/env

# ghcup
if ! which ghc || ! which cabal; then
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org > /tmp/ghcup
    chmod u+x /tmp/ghcup
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=latest BOOTSTRAP_HASKELL_CABAL_VERSION=latest /tmp/ghcup
fi
source ~/.ghcup/env


USED_NVM=0
if ! which npm || ! which node || ! node --version | grep 'v2[456789]'; then
    USED_NVM=1
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
    source "$HOME/.nvm/nvm.sh"
    nvm install 24
    nvm use 24
fi


echo -e "\nSuccessfully installed rottnest pre-reqs. Installing rottnest."
echo "Creating default rottnest config"
mkdir -p ~/.config/rottnest
echo "t_scheduler" >> ~/.config/rottnest/architectures
echo "rottnest_example_executables" >> ~/.config/rottnest/executables

make

echo "Installed rottnest."

if [ $USED_NVM -eq 1 ]; then
    echo "Nodejs was installed using nvm. You may need to restart your shell to ensure the version of node on PATH is correct."
fi
