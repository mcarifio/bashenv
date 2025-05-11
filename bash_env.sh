# export BASH_ENV="${this_files_fqpn}"
# declare -axg BASH_ENVS=( pn0 pn1 ... )

dot2dash() ( echo "${1//./_}"; )

bash_env.require.init() {
    local _prefix=_$(dot2dash ${FUNCNAME%.*})$$
    declare -Aixg ${_prefix}_timestamps=() ${_prefix}_statuses=()
}
f.x bash_env.require.init

bash_env.require() {
    local _prefix=_$(dot2bash ${FUNCNAME})$$
    declare -Aixg ${_prefix}_timestamp ${_prefix}_status
    declare -nur _timestamp=${_prefix}_timestamps
    declare -nur _status=_${_prefix}_statuses
    local _fqpn=$(realpath -q "${1:?'expecting a pathname'}")

    [[ -v _timestamp["${_fqpn}" ]] && (( $(stat %+Y "${_fqpn}") < ${_timestamp["${_fqpn}"]} ))  && return 0
    [[ -r "${_fqpn}"  ]] && {
        source"${_fqpn}"
        _statuses["${_fqpn}"]=$?
        _timestamps["${_fqpn}"]=$(date +%s)
    }
}
f.x bash_env.require

bash_env.require.all() {
    ${FUNCNAME}.init
    local _prefix=_$(dot2dash ${FUNCNAME%%.*})$$
    declare -Aixg ${_prefix}_timestamps ${_prefix}_statuses
    declare -nur _timestamps=${_prefix}_timestamps
    declare -nur _statuses=_${_prefix}_statuses

    local -ur _export=${_prefix}
    declare -nur _requires=${_export}
    [[ -v _requires ]] && >&2 echo "missing '${_requires}'?"
    
    for _pn in "${_requires}" $@"; do require ${_pn}; done
}
export -fx bash_env.requires


bash_env.required() {
    local _prefix=_${FUNCNAME%.*}$$
    declare -nur _timestamps=${_prefix}_timestamps
    declare -nur _statuses=_${_prefix}_statuses
    declare -Aixg ${_prefix}_timestamps=() ${_prefix}_statuses=()

    for _pn in "${_bash_envs[@]}" $@"; do
        local _fqpn=$(realpath -q "${_pn}")
        (( _status&&=_sourced_status["${_fqpn}"] )) && _sourced_timestamp["${_fqpn}"]=$(date +%s)
        }
    done        
    && -v _sourced_timestamp && -v _sourced_status ]] || return 1
    for _pn in ${#_sourced[@]}"
}
export -fx bash_envs.sourced

bash_envs.source "$@"
[[ -n "${DEBUG}" ]] && bash_envs.sourced


