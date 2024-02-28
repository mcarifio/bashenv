_template.parsed() (
    : 'tbs'
    set -uEeo pipefail; shopt -s nullglob
    local _file="${PWD}/${FUNCNAME}"
    local _comment="${HOSTNAME}:${_file}"
    local _password=''
    local _trace='+x'
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--file=*) _file=${_a#--*=};;
		--comment=*) _comment=${_a#--*=};;
		--password=*) _password=${_a#--*=};;
		--trace) _trace='-x';;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    echo ${FUNCNAME};
    
)
___template.parsed.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig _arg_start _arg_rest
    COMPREPLY=()
    # flags
    if [[ "-" == ${word[0]} ]]; then
	COMPREPLY=( compgen -W "--file= --comment= --password= --trace" -- "${_word}")
	_arg_start=$(( ++_position ))
    elif (( _position == _arg_start)); then
	if (( __previous_position != _position )) && [[ -z "${_word}" ]] ; then
	    >&2 echo -n "(required|optional type) "
	else
	    COMPREPLY=( some completions here )
	fi
	__arg_rest=0
    elif (( _position > 1 && __previous_position != _position )); then
	>&2 echo -n "(rest...) "
	__arg_rest=1	
    fi
    let __previous_position=_position
}

f.complete _template.parsed


_template.env() {
    # echo ${FUNCNAME}
    return 0 
}
f.complete _template.env
