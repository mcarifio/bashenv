#!/usr/bin/env bash
set -Eeuo pipefail

_post.install() (
    # after installation configuration
    >&2 echo "${FUNCNAME} $@ # ${FUNCNAME} tbs"
)


# see install.lib.sh for install variants
_install() (
    local _kind=${1:-distro}; shift || true
    # install.$(os.release ID) "$@"
    local _name=${1:?'expecting a name'}; shift || true
    install.${_kind} ${_name} "$@"
    # _post.install "$@"
    install.check ${_name}
)

_install $(path.basename.part $(basename ${BASH_SOURCE}) 2) $(path.basename ${BASH_SOURCE}) "$@"

