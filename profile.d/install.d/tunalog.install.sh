#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.go "${2:?'expecting a url'}"
    install.check "${1:?'expecting a command'}"
)

install $(path.basename ${BASH_SOURCE}) "github.com/caris-events/tunalog@latest" "$@"

