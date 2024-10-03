# .bash_profile

next() ( echo "${1:?"${FUNCNAME} needs an initializer name"} [--trace] ## next" >&2; ) 

if [[ -n "${SSH_CONNECTION}" ]]; then
    echo "ssh from ${SSH_CLIENT}" >&2
    next
    return 0
fi

bashenv.start() {
    local _bashenv=$(dirname $(realpath -Lm ${BASH_SOURCE}))
    local _initializer=${FUNCNAME%.*}.init

    for _l in ${_bashenv}/*.lib.sh; do
        source ${_l}
    done

    if [[ -e "${HOME}/${_initializer}" ]]; then
        echo "${_initializer} $(< ${HOME}/${_initializer})" >&2
        ${_initializer} $(< ${HOME}/bashenv.init)
    else
        next ${_initializer}
    fi
}

bashenv.start bashenv.init
