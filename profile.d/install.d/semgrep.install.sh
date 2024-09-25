#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.pip "$@"
    install.check $1
)

install $(path.basename ${BASH_SOURCE}) "$@"

