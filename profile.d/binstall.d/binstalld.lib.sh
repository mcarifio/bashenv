set -Eeuo pipefail; shopt -s nullglob
source $(u.here)/../binstall.source.sh

binstalld.dispatch() (
    >&2 echo ${FUNCNAME} $@
    set -Eeuo pipefail; shopt -s nullglob
    local _kind=tbs _postinstall=''
    local -a _cmds=()
    u.have ${FUNCNAME##*.} || return $(u.error "${$FUNCNAME}: ${FUNCNAME##*.} not on path, stopping.")
    
    for _a in "$@"; do
        local _v="${_a##*=}"
        case "${_a}" in
	    --kind=*) _kind="${_v}";;
            --cmd=*) _cmds+="${_v}";;
            --postinstall=*) _postinstall="${_v}";;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    local _installer=binstall.${_kind}
    ${_installer} $@ || return $(u.error "${FUNCNAME} ${_installer} failed")
    if ! (( ${#_cmds[@]} )) ; then
        [[ dnf = ${_kind} ]] && _cmds=( $(rpm -ql ${_pkg[@]} | grep --extended-regexp '^/usr/s?bin/') )
    fi
    [[ -n "${_postinstall}" ]] && ${_postinstall}
    binstall.check ${_cmds[@]} >&2
)
