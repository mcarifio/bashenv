#!/usr/bin/env bash
set -Eeuo pipefail

# TODO mike@carif.io: configure ptyxis for ${USER} after installation
post.install() (
    # after installation configuration
    >&2 echo "${FUNCNAME} $@ # placeholder does nothing currently"
)

install() (
    install.distro "$@"
    # post.install "$@"
    install.check "$1"
)

install $(path.basename ${BASH_SOURCE}) "$@"

