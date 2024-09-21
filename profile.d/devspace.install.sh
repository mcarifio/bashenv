#!/usr/bin/env bash
set -Eeuo pipefail

_post.install() (
    # after installation configuration
    >&2 echo "${FUNCNAME} $@ # placeholder does nothing currently"
)


# see install.lib.sh for install variants
_install() (
    local _kind=${1:-distro}; shift || true
    # install.$(os.release ID) "$@"
    local _name=${1:?'expecting a name'}; shift || true
    install.${kind} ${_name} "$@"
    # _post.install "$@"
    install.check ${_name}
)

# install "$@"
# install $(path.basename ${BASH_SOURCE}) "$@"
_install asdf $(path.basename ${BASH_SOURCE}) "$@"

