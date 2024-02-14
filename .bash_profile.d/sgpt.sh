realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
type -p sgpt &> /dev/null || return 0

sgpt.fix() (
    : 'sgpt.fix [--what=package] --on=[linux] ... additional advice'
    set -uEeo pipefail
    local _what='' # program or package
    local _on=$(os-release.name-version) # taken from /etc/os-release
    local _using=$(u.shell) # usually bash
    local -i _code=0
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--what=*) _what=${_a#--what=};;
		--on=*) _on=${_a#--on=};;
		--using=*) _using=${_a#--using=};;
		--code) _code=1;;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    local _query=''
    _query+=${FUNCNAME##*.}
    [[ -n "${_from}" ]] && _query+=" ${_what} "
    [[ -n "${_on}" ]] && _query+=" on operating system ${_on} "
    [[ -n "${_using}" ]] && _query+=" using ${_on} "
    (( ${#@} )) && _query+=" with symptoms $@"

    local _sgpt='sgpt '
    (( _code )) && _sgpt+=' --code '

    # >&2 echo "# ${_query}"
    (set -x; ${_sgpt} "${_query}")
)


sgpt.install() (
    : 'sgpt.install [--code] [--what=something] --on=[linux] --using=${shell} ... additional advice'
    set -uEeo pipefail
    local _what='' # program or package
    local _on=$(os-release.name-version) # taken from /etc/os-release
    local _using=$(u.shell) # usually bash
    local -i _code=0
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--what=*) _what=${_a#--what=};;
		--on=*) _on=${_a#--on=};;
		--using=*) _using=${_a#--using=};;
		--code) _code=1;;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    local _query=''
    _query+=${FUNCNAME##*.}
    [[ -n "${_what}" ]] && _query+=" ${_what} "
    [[ -n "${_on}" ]] && _query+=" on operating system ${_on} "
    [[ -n "${_using}" ]] && _query+=" using ${_using} "
    (( ${#@} )) && _query+=" with advice $@"

    local _sgpt='sgpt '
    (( _code )) && _sgpt+=' --code '

    # >&2 echo "# ${_query}"
    (set -x; ${_sgpt} "${_query}")

); declare -fx sgpt.install
