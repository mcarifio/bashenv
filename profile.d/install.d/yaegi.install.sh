#!/usr/bin/env bash
set -Eeuo pipefail

# install() ( install.$(os.release ID) "$@"; )
install() (
    install.distro rlwrap # prerequisite
    install.go "${2:?'expecting a url'}"
    install.check "${1:?'expecting a command'}"
)

install $(path.basename ${BASH_SOURCE}) "github.com/traefik/yaegi/cmd/yaegi@latest" "$@"

