#!/bin/zsh

set -e

if ! which brew; then
  echo "Rottnest needs homebrew to install its dependencies, please install homebrew before running mac setup"
  exit 1
fi

# GNUMake (up-to-date thru brew)
if ! which gmake; then
    brew install -y make
fi

# Python (brew)
PYTHON_TARGET=""

if which python3.11; then
  PYTHON_TARGET=python3.11
elif which python3; then
  PYTHON_TARGET=python3;
elif which python; then
  PYTHON_TARGET=python;
fi

# Version check
if [[ ! -z "$PYTHON_TARGET" ]]; then
  # If version is not 3.11, the given version is invalid
  if ! "$PYTHON_TARGET" --version | grep "3.11"; then
    PYTHON_TARGET=""
  fi
fi

if [[ -z "$PYTHON_TARGET" ]]; then
  echo "Could not find a python3.11 installation, installing it via brew"
  brew install -y python@3.11
  PYTHON_TARGET=python3.11
  echo "Installed python under the name python3.11"
fi

# GHC (ghcup)
if ! which ghc || ! which cabal; then
  echo "Could not find a ghc installation, installing it via ghcup"
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org > /tmp/ghcup
  chmod u+x /tmp/ghcup
  BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=latest BOOTSTRAP_HASKELL_CABAL_VERSION=latest /tmp/ghcup
  source ~/.ghcup/env
  cabal update
else
  cabal update
fi

# rust (brew)
if ! which rustc || ! which cargo; then
  echo "Could not find a rust installation, installing it via brew"
  brew install -y rust
fi


# npm (brew)
if ! which npm; then
  echo "Could not find a node installation, installing it via brew"
  brew install -y node
fi

# docker (brew)
if ! which docker; then
    echo "Could not find a docker installation, installing it via brew"
    brew install -y --cask docker-desktop
    brew install -y docker-buildx
fi


if ! python --version | grep "3.11"; then
  echo
  echo "Python was found, but 'python' does not point to the right version. Please ensure that the version of 'python' available on PATH is python 3.11, then run this script again. If python was installed by this script, you can use 'python3.11 -m venv ./venv', and then 'source ./venv/bin/activate;. Once python points to the correct version, rerun this script to continue the installation."
  exit 1
fi



# create default config files
echo "Creating default rottnest config"
mkdir -p ~/.config/rottnest
echo "t_scheduler" >> ~/.config/rottnest/architectures
echo "rottnest_example_executables" >> ~/.config/rottnest/executables

echo "Installing rottnest. You may get a window regarding docker if it was not already installed."

gmake

echo "Installed rottnest."
