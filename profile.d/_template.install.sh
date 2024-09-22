#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob

_post.install() (
    local _name=${1:?'expecting a name'}
    install.check ${_name}
)


# see install.lib.sh for install variants
_install() (
    local _kind=${1:-distro}; shift
    local _name=${1:?'expecting a name'}; shift
    install.${_kind} ${_name} "$@"
    _post.install "${_name}" "$@"
)

[[ "$0" = */bashdb ]] && shift
_install $(path.basename.part "$0" 1) $(path.basename "$0") "$@"

