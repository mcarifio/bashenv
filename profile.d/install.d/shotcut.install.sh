#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

# https://www.shotcut.org/
install() (
    install.distro "$@"
    install.check "$1"
)

install $(path.basename ${BASH_SOURCE}) "$@"

