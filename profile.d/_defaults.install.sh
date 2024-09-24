_post.install() (
    set -Eeuo pipefail; shopt -s nullglob
    local -r _name=${1:?'expecting a name'}
    install.check ${_name}
)

_install() (
    set -Eeuo pipefail; shopt -s nullglob
    local -r _kind=${1:-distro}; shift
    local -r _name=${1:?'expecting a name'}; shift
    install.${_kind} ${_name} "$@"
    _post.install "${_name}" "$@"
)

_installx() (
    set -Eeuo pipefail; shopt -s nullglob
    local _kind=distro _pkg _cmd

    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--kind=*) _kind="${_a##*=}";;
                --pkg=*) _pkg="${_a##*=}";;
                --cmd=*) _cmd="${_a##*=}";;
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi
    
    [[ -n "${_pkg:-}" ]] || return $(u.error 'expecting --pkg=${something}')
    install.${_kind} ${_pkg} "$@"
    _post.install "${_cmd:-${_pkg}}"
)

