scheme.parsed() (
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
__scheme.parsed.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig _arg_start _arg_rest
    COMPREPLY=()
    # echo; echo _word ${_word} _previous_word ${_previous_word}
    # flags
    if [[ ${_word} == --file=* ]]; then
	__arg_rest=0
	COMPREPLY=( $(compgen -f -- ${_word##*=}) )
    elif [[ ${_word} == -?(-)* ]]; then
	__arg_rest=0
	COMPREPLY=( $(compgen -W "--file= --comment= --password= --trace" -- "${_word}") )
	[[ ${COMPREPLY-} == *= ]] && compopt -o nospace; # --flag= doesn't add space
	_arg_start=$(( _position + 1 ))
    elif (( _position == _arg_start)); then
	__arg_rest=1	
	if (( __previous_position != _position )) && [[ -z "${_word}" ]] ; then
	    >&2 echo -n " (required|optional type) "
	else
	    COMPREPLY=( some completions here )
	fi
    elif (( _position > ${_arg_start} && __previous_position != _position )); then
	__arg_rest=1	
	>&2 echo -n " (rest...) "
    fi
    let __previous_position=_position
}

f.complete scheme.parsed

scheme() ( $(which racket guile) "$@" || u.error "${FUNCNAME} not found"; )
f.complete scheme


scheme.env() {
    # false || return $(u.error "${FUNCNAME} failed")
    :
}
f.complete scheme.env

scheme.session() {
    # false || return $(u.error "${FUNCNAME} failed")
    :
}
f.x scheme.session
