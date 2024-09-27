#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob

o.var() ( local _v=${1%=*}; echo "_${_v:2}"; )
o.val() ( echo "${1##*=}"; )
# o.required() {
#     local -gn _v=$1
#     echo ${FUNCNAME} $1 ${_v} || true
#     [[ -n "${_v}" ]] && return 0
#     >&2 echo "${FUNCNAME[-2]} expecting --${1:1}=\${something}"
#     return 1
# }

example.options() (
    set -Eeuo pipefail; shopt -s nullglob
    >&2 echo ${FUNCNAME} "$@"


    local -i _bool=0
    # _var required, see check below
    local _var='_var' _varo='_varo'
    >&2 declare -p _var _varo _bool

    for _a in "${@}"; do
        case "${_a}" in
            --bool) _bool=1;; ## turn _bool on
            --var=*) _var="${_a##*=}";; ## manual
            --varo=*) local -n _lhs=$(o.var ${_a}); _lhs="$(o.val ${_a})";  >&2 printf '_lhs: %s, _varo: %s ## --varo case\n' ${_lhs} ${_varo};; ## regardless of variable
	    --do=*) echo "${_a%=*} ${_a##*=} ## --do case";; ## do something manually
            --doo=*) local -n _lhs=$(o.var ${_a}); _lhs="$(o.val ${_a})"; >&2 printf '_lhs: %s ## --doo case\n' ${_lhs};;
            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    # required _var check
    # o.required _var
    # o.required _boo || true
    [[ -z "${_var:-}" ]] && >&2 echo "_var has no required value, use --var=\${something}"
    >&2 declare -p _var _varo _bool
    local _first=${1:?'expecting an argument'}; shift
    >&2 declare -p _first
    >&2 echo -e "$@\n\n"
)

# required() (
#     local -rg _r=''
#     declare -p _r
#     o.required _r
# )


example.options no options ${LINENO}
example.options --bool just bool  ${LINENO}
example.options --do=something just something else  ${LINENO}
example.options --var=${USER} just var  ${LINENO}
example.options --varo=oh just varo  ${LINENO}
example.options --doo='doo doo'  ${LINENO}
example.options --var=100 --bool --do='something else' --varo=200 --doo=dowhop all options  ${LINENO}
example.options --bool -- --var=100 short circuit  ${LINENO}

# required
