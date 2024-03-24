# usage: source duckdb.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [summarize]=0 [trace]=0)
_undo=''
trap -- 'eval ${_undo}; unset _option _trap; trap -- - RETURN' RETURN

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
        # asdf plugin-list --urls
        asdf.install --url=https://github.com/jtzero/asdf-duckdb.git
        duckdb --version
    fi
fi

_duckdb.parsed() (
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

# TODO mike@carif.io: logic needs fixing
___duckdb.parsed.complete() {
    :
}

f.complete _duckdb.parsed


duckdb.env() {
    # >&2 echo  "${FUNCNAME} tbs"
    :
}
f.x duckdb.env

duckdb.session() {
    # >&2 echo "${FUNCNAME} tbs"
    :
}
f.x duckdb.session
duckdb.session

