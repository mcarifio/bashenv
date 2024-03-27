# usage: source _template.guard.sh [--install] [--verbose] [--trace]

# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        u.bad "${BASH_SOURCE} --install # not implemented"
    fi
fi

# not working
_template.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _template_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _template_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _template_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
___template.parse.complete() {
    :
}

f.complete _template.parse


_template.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x _template.env

_template.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x _template.session

loaded "${BASH_SOURCE}"
