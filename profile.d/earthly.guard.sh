# usage: source _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''
trap -- 'eval ${_undo}; unset _option _undo _guard; trap -- - RETURN' RETURN

if (( ${#@} )) ; then
    for _a in "$@"; do
        case "${_a}" in
            # --something=some_value => _option[something]=some_value
            --*=*) [[ "${_a}" =~ --([^=]+)=(.+) ]] && _option[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}";;
            # --something => _option[something]=1
	    --*) _option[${_a:2}]=1;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done
fi
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        bashenv.exe.install https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 ${HOME}/.local/bin/${_guard}
        command ${_guard} --version
    fi
fi

_earthly.parsed() (
    : '## template function that parses flags'
    set -uEeo pipefail
    shopt -s nullglob
    local _file="${PWD}/${FUNCNAME}"
    local _comment="${HOSTNAME}:${_file}"
    local _password=''
    local _trace='+x'
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--file=*) _file=${_a##*=};;
		--comment=*) _comment=${_a##*=};;
		--password=*) _password=${_a##*=};;
		--trace) _trace='-x';;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    echo ${FUNCNAME} ${_file} ${_comment} ${_password} ${_trace} "$@"    
)
f.x _earthly.parsed


earthly.env() {
    # >&2 echo  "${FUNCNAME} tbs"
    :
}
f.x earthly.env

earthly.session() {
    # >&2 echo "${FUNCNAME} tbs"
    earthly bootstrap --with-autocomplete
}
f.x earthly.session
