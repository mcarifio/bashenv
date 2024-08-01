#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/install.lib.sh

# install() ( install.$(os.release ID) "$@"; )
# https://github.com/eza-community/eza
install() (
    install.$(os.release ID) "$@"
    install.check "$1"
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
install $(path.basename ${BASH_SOURCE}) "$@"

