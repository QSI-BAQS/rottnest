#!/bin/env

chmod +x /tmp/ghcup
/tmp/ghcup install 8.6.5
/tmp/ghcup set 8.6.5
/tmp/ghcup install-cabal 2.4.1.0

# Update path
PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

# Install Quipper
cabal update
cabal install quipper-all
