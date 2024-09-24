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
    local _kind=distro _pkg='' _cmd=''

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
    
    [[ -z "${_pkg:-}" ]] && return $(u.error 'expecting --pkg=${something}')
    install.${_kind} ${_pkg} "$@"
    [[ -z "${_cmd}" ]] && { _cmd=$(rpm -ql ${_pkg} | grep --max-count=1 --basic-regexp '^/usr/bin/'); >&2 echo "${_pkg} seems to install ${_cmd}, continuing..."; }
    _post.install "${_cmd}"

)

