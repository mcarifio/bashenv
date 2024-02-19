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
		--file=*) _file=${_a#--file=};;
		--comment=*) _comment=${_a#--comment=};;
		--password=*) _password=${_a#--password=};;
		--trace) _trace='-x';;
		
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    echo ${FUNCNAME};
    
); declare -fx _template.parsed


_template.env() {
    echo ${FUNCNAME}
    return 0 
}; declare -fx _template.env
