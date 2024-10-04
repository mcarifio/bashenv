# .bash_profile

next() ( printf '%s %s\n' ${1:?"${FUNCNAME} needs an initializer name"} "[--trace] ## ${FUNCNAME}" >&2; ) 


bashenv.start() {
    local _bashenv="$(dirname $(realpath -Lm ${BASH_SOURCE}))" ## .bash_profile is a symlink to bashenv/.bash_profile
    # declare -p _bashenv
    local _initializer=${1:-${FUNCNAME%.*}.init}
    # declare -p _initializer
    local _pathname="${HOME}/${_initializer}"
    # declare -p _pathname

    # Source all the local libraries. Unfortunately order matters, so this has limited usefulness.
    for _l in ${_bashenv}/*.lib.sh; do
        # declare -p _l
        source ${_l}
    done

    if [[ -n "${SSH_CONNECTION}" ]]; then
        echo "${HOSTNAME} ssh connection ${SSH_CONNECTION}" >&2
        next "${_initializer}"
        return 0
    fi
    
    # ${_initializer} plays a role similar to hushlogin.
    if [[ -e "${_pathname}" ]]; then
        echo "${_initializer} $(< ${_pathname}) ## found ${_pathname}" >&2
        ${_initializer} $(< ${_pathname})
    else
        next "${_initializer}"
    fi
}

bashenv.start bashenv.init
