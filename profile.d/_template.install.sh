#!/usr/bin/env bash
set -Eeuo pipefail

post.install() (
    # after installation configuration
    >&2 echo "${FUNCNAME} $@ # placeholder does nothing currently"
)


# see install.lib.sh for install variants
install() (
    install.$(os.release ID) "$@"
    # post.install "$@"
    install.check "$1"
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
install $(path.basename ${BASH_SOURCE}) "$@"

