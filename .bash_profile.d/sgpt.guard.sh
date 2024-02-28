sgpt.fix() (
    : 'sgpt.fix [--what=package] --on=[linux] ... additional advice'
    set -uEeo pipefail
    local _what='' # program or package
    local _on=$(os-release.name-version) # taken from /etc/os-release
    local _using=$(u.shell) # usually bash
    local -i _code=0
    local _flags=''
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--what=*) _what=${_a#--what=};;
		--on=*) _on=${_a#--on=};;
		--using=*) _using=${_a#--using=};;
		--code) _code=1; __flags+='--code ';;
		
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

    # >&2 echo "# ${_query}"
    (set -x; command sgpt ${_flags} "${_query}")
)
f.complete sgpt.fix

sgpt.install() (
    : 'sgpt.install [--code] [--what=something] --on=[linux] --using=${shell} ... additional advice'
    set -uEeo pipefail
    local _what='' # program or package
    local _on=$(os-release.name-version) # taken from /etc/os-release
    local _using=$(u.shell) # usually bash
    local -i _code=0
    local _flags=''
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--what=*) _what=${_a#--what=};;
		--on=*) _on=${_a#--on=};;
		--using=*) _using=${_a#--using=};;
		--code) _code=1; _flags+='--code ';;
		
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

    # >&2 echo "# ${_query}"
    (set -x; command sgpt ${_flags} "${_query}")

)
f.complete sgpt.install
