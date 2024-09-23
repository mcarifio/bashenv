_post.install() (
    set -Eeuo pipefail; shopt -s nullglob
    local _name=${1:?'expecting a name'}
    install.check ${_name}
)

_install() (
    set -Eeuo pipefail; shopt -s nullglob
    local _kind=${1:-distro}; shift
    local _name=${1:?'expecting a name'}; shift
    install.${_kind} ${_name} "$@"
    _post.install "${_name}" "$@"
)

