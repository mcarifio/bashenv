# export BASH_ENV="${this_files_fqpn}"
# declare -axg BASH_ENVS=( pn0 pn1 ... )


missing() ( printf "${2:-${FUNCNAME[1]}} missing ${1:-argument} " >&2; return 1; )
f.x missing

isa.argument() ( true; )
isa.pathname-r() ( [[ -r "${1:?$(missing pathname)}" ]]; )
isa.Aref() ( true; )
isa.aref() ( true; )
isa.ref() ( [[ -R ${1:?$(missing ref)} ]]; )
isa() (
    local -n _ref=${2:?$(missing ref)}
    [[ -R _ref ]] || return $(u.error "missing ref ${2}")
    local _checker=${FUNCNAME}.${1:-argument}
    f.exists ${_checker} || return $(u.error "missing checker '${_checker}'")
    ${_checker} ${_ref} || return $(u.error "'${_ref}' fails '${_checker}'")
    return 0
)
f.x $(f.match ^isa)

source.by-name() {
    local _pathname="${1:?$(missing _pathname)}"
    isa pathname-r _pathname || false
    local _name="${2:?$(missing _name)}"
    source <(awk "/^${func}[[:space:]]*\\(\\)/,/^}/" "${_pathname}")
}
f.x source.by-name

dot2dash() ( echo "${1//./_}"; )
f.x dot2dash

# bash_env.require.init() {
#     local _kind=${1:?'missing kind'}; shift
#     local _args="$@"
#     local -n _bash_env_v
#     for _bash_env_v in _$(dot2dash ${FUNCNAME%.*})_{${args// /,}}$$; do
#         declare -${_kind}g ${_v}
#         ${_v}=()
#     done
# }
# f.x bash_env.require.init


be.init.vars() {
    local _decl=${1:?$(missing decl)}; shift
    local -a _result=()
    for _r in "$@"; do
        # gross
        unset "${_r}"
        # declare ${_decl} "${_r}=()" && _result+=( ${_r} )
        declare ${_decl} "${_r}" && _result+=( ${_r} )
    done
    # declare -p "$@" >&2
    echo ${_result[@]}
}
be.name() {
    local _prefix=${1:?$(missing _prefix)}; shift
    printf "__${_prefix}_%s_$$" "$@"
}
be.names() {
    local _prefix=${1:?$(missing _prefix)}; shift
    for _n in "$@"; do echo $(be.name ${_prefix} ${_n}); done
}
be.init() {
    local _decl=${1:?$(missing decl)}; shift
    local _prefix=${1:?$(missing _prefix)}; shift
    # declare -a _names=( $(be.init.names "${_prefix}" "$@") )
    # be.init.literal ${_decl} "${_names[@]}"
    be.init.vars ${_decl} $(be.names "${_prefix}" "$@")
}
be.require.init() {
    # _parts, the FUNCNAME as an array; get pos 1.
    declare -a _parts=( ${FUNCNAME//./ } )
    be.init Aixg ${_parts[1]} timestamp status
}
be.require() {
    local _prefix=$(dot2dash ${FUNCNAME#.*})
    local -n _timestamp="$(be.name ${_prefix} timestamp)"
    local -n _status="$(be.name ${_prefix} status)"
    local _fqpn=$(realpath -q "${1:?$(missing pathname)}")

    [[ -v _timestamp["${_fqpn}"] ]] && (( $(stat %+Y "${_fqpn}") < ${_timestamps["${_fqpn}"]} ))  && return 0
    [[ -r "${_fqpn}"  ]] && {
        source "${_fqpn}" && _status["${_fqpn}"]=$?
        _timestamp["${_fqpn}"]=$(date +%s)
    }
}
map.be.require() {
    ${FUNCNAME#*.}.init
    ${FUNCNAME%.*} ${FUNCNAME#*.} "$@"
}
    
    
be.parse() (
    local -n _be_switches_A _be_forwards_A _be_args_a
    # isa.Aref _be_switches_A A
    # isa.aref _be_switches_A A
    # isa.ref _be_args_a a
    for _a in "$@"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"; 
        case "${_a}" in
            # shortcircuit switches
            --) shift; break;;
            # switch
            --*) [[ -v _switches_A[${_k}] && _switches_A[${_k}]=${_v:-1} ]] || _forwards_A[${_k}]=${_v:-1};;
        esac
        shift
    done
    _be_args+=( $@ );
)
f.x $(f.match ^be\\.)

# bash_env.required() {
#     local _prefix=_${FUNCNAME%.*}$$
#     declare -nur _timestamps=${_prefix}_timestamps
#     declare -nur _statuses=_${_prefix}_statuses
#     declare -Aixg ${_prefix}_timestamps=() ${_prefix}_statuses=()

#     for _pn in "${_bash_envs[@]}" $@"; do
#         local _fqpn=$(realpath -q "${_pn}")
#         (( _status && _sourced_status["${_fqpn}"] )) &&
#             _sourced_timestamp["${_fqpn}"]=$(date +%s) && \
#             [[ -v _sourced_timestamp ]] && [[ -v _sourced_status ]] || return 1

#     done        
#     for _pn in ${#_sourced[@]}"
# }
# f.x bash_envs.sourced

# bash_env.require.all "$@"

[[ -n "${DEBUG}" ]] && bash_envs.sourced
