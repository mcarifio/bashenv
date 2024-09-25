#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.asdf "$@"    
    install.check "$1"
)

install $(path.basename ${BASH_SOURCE}) "$@"

