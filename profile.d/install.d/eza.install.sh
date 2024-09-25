#!/usr/bin/env bash
set -Eeuo pipefail

# https://github.com/eza-community/eza
install() (
    install.distro "$@"
    install.check "$1"
)

install $(path.basename ${BASH_SOURCE}) "$@"

