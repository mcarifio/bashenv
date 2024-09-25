#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.brew elan-init
    elan-init lean
    install.check $1
)

install "$@"

