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
