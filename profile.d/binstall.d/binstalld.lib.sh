set -Eeuo pipefail; shopt -s nullglob
# set -x; source $(u.here)/../binstall.source.sh

binstalld.dispatch() (
    set -Eeuo pipefail; shopt -s nullglob
    local _kind=tbs _pkg='' _postinstall=''
    local -a _cmds=()
    u.have ${FUNCNAME##*.} || return $(u.error "${$FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")
    
    for _a in "${@}"; do
        case "${_a}" in
	    --kind=*) _kind="${_a##*=}";;
            --pkg=*) _pkg="${_a##*=}";;
            --cmd=*) _cmds+="${_a##*=}";;
            --postinstall=*) _postinstall="${_a##*=}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    [[ -z "${_pkg}" ]] && return $(u.error "${FUNCNAME} needs --pkg=\${something}")

    local _installer=binstall.${_kind}
    ${_installer} --pkg="${_pkg}" "$@" >&2 || return $(u.error "${FUNCNAME} ${_installer} failed")
    if ! (( ${#_cmds[*]} )) ; then
        [[ dnf = ${_kind} ]] && _cmds=( $(rpm -ql ${_pkg} | grep --basic-regexp '^/usr/bin/') ) || _cmds+=${_pkg}
    fi
    [[ -n "${_postinstall}" ]] && ${_postinstall} --pkg=${_pkg}
    binstall.check ${_cmds[*]} >&2
)
