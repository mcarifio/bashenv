#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export GHCUP_USE_XDG_DIRS=1
export BOOTSTRAP_HASKELL_VERBOSE=1
export BOOTSTRAP_HASKELL_ADJUST_BASHRC=0
export BOOTSTRAP_HASKELL_GHC_VERSION=latest
export BOOTSTRAP_HASKELL_CABAL_VERSION=latest
export BOOTSTRAP_HASKELL_STACK_VERSION=latest
export BOOTSTRAP_HASKELL_HLS_VERSION=latest

# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --url="https://get-ghcup.haskell.org" \
         "$@"
# post install
