#!/bin/bash

# Pre-check apt packages, since we aren't going to install them here (no sudo)
export ALL_PKGS="$(apt list --installed 2>/dev/null)"

REQUIRED="git curl gcc build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libffi8 libgmp-dev libgmp10 libncurses-dev pkg-config npm docker-ce docker-ce-cli docker-buildx-plugin"

MISSING=""

for REQ in $REQUIRED; do
    if [[ "$(echo "$ALL_PKGS" | grep "$REQ" >/dev/null; echo "$?")" -ne 0 ]]; then
        MISSING="$REQ $MISSING"
    fi
done

if [[ "$MISSING" != "" ]]; then
    echo -e "The following required packages are missing:\n $MISSING"
    echo -e "\nPlease install them using apt\n"
    echo -e "NOTE: Docker packages must be installed from docker's apt repository\nSee https://docs.docker.com/engine/install/ubuntu/, section 'Install using the apt repository'"
    exit 1
fi

echo "Installing rottnest prerequisites that aren't provided by apt"
echo "You may see warnings about reinstallations. These should be fine"

# pyenv
curl -fsSL https://pyenv.run > /tmp/pyenv-installer
chmod u+x /tmp/pyenv-installer
/tmp/pyenv-installer -y

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

pyenv install 3.11 -f
pyenv global 3.11

# rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup
chmod u+x /tmp/rustup
/tmp/rustup -y
source ~/.cargo/env

# ghcup
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org > /tmp/ghcup
chmod u+x /tmp/ghcup
BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=latest BOOTSTRAP_HASKELL_CABAL_VERSION=latest /tmp/ghcup
source ~/.ghcup/env


echo -e "\nSuccessfully installed rottnest pre-reqs. Installing rottnest inside a local virtual environment"

python3 -m venv ./venv
source venv/bin/activate

make

echo "Installed rottnest. Please use 'source venv/bin/activate' to enable the associated version of python"
