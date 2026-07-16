#!/bin/zsh

set -e

if [[ "$EUID" -eq 0 ]]; then
  echo "This script should not be run as root, please rerun without sudo"
  exit 1
fi

if ! which brew; then
  echo "Rottnest needs homebrew to install its dependencies, please install homebrew before running mac setup"
  exit 1
fi

if ! which python || ! python --version | grep "3.11"; then
  echo "Rottnest requires that 'python' on PATH is python 3.11. Please configure your python environment such that the correct version is available under the name 'python'"
  exit 1
fi

# GNUMake (up-to-date thru brew)
if ! which gmake; then
    brew install -y make
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


# create default config files
echo "Creating default rottnest config"
mkdir -p ~/.config/rottnest
echo "t_scheduler" >> ~/.config/rottnest/architectures
echo "rottnest_example_executables" >> ~/.config/rottnest/executables

echo "Installing rottnest. You may get a window regarding docker if it was not already installed."

gmake

echo "Installed rottnest."
