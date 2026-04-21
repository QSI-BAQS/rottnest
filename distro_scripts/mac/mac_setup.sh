#!/bin/zsh

set -e

if ! which brew; then
  echo "Rottnest needs homebrew to install its dependencies, please install homebrew before running mac setup"
  exit 1
fi

# GNUMake (up-to-date thru brew)
if ! which gmake; then
    brew install make
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
  brew install python@3.11
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
  brew install rust
fi


# npm (brew)
if ! which npm; then
  echo "Could not find a node installation, installing it via brew"
  brew install node
fi

echo -e "Successfully installed rottnest dependencies. Creating a virtual environment at ./venv"
$PYTHON_TARGET -m venv ./venv
source venv/bin/activate

gmake

echo "Installed rottnest. Please use 'source venv/bin/activate' to enable the associated version of python"
