# .bash_profile

bashenv.start() {
    : '${_initializer} ## the function that initializes the bash environment'
    # _initializer is a little misleading since $(bashenv.root)/*.lib.sh is sourced regardless.

    local _bashenv="$(dirname $(realpath -Lm ${BASH_SOURCE}))" ## .bash_profile is a symlink to bashenv/.bash_profile
    local _initializer=${1:-${FUNCNAME%.*}.init}
    local _echo=${2:-noecho}
    local _pathname="${HOME}/${_initializer}"

    # Source all the local libraries. Unfortunately order matters, so this has limited usefulness.
    for _l in ${_bashenv}/*.lib.sh; do
        # declare -p _l
        # always source ${_l} even if it's been sourced previously
        source ${_l} ${_echo}
    done

    if [[ -n "${SSH_CONNECTION}" ]]; then
        echo "${HOSTNAME} ssh connection ${SSH_CONNECTION}" >&2
        printf '%s\n' "${_initializer} [--trace] ## next" >&2
        return 0
    fi
    
    # ${_initializer} plays a role similar to hushlogin.
    if [[ -e "${_pathname}" ]]; then
        echo "${_initializer} $(< ${_pathname}) ## found ${_pathname}" >&2
        ${_initializer} $(< ${_pathname})
    else
        printf '%s\n' "${_initializer} [--trace] ## next" >&2
    fi
}

bashenv.start bashenv.init
f.x bashenv.start

