#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/install.lib.sh

# install() ( install.$(os.release ID) "$@"; )
install() (
    set -Eeuo pipefail
    install.distro rlwrap # prerequisite
    install.go "${2:?'expecting a url'}"
    install.check "${1:?'expecting a command'}"
)

install $(path.basename ${BASH_SOURCE}) "github.com/traefik/yaegi/cmd/yaegi@latest" "$@"

