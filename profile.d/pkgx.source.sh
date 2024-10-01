# usage: [guard | source] ${guard}.guard.sh [--install] [--verbose] [--trace]
# creation: guard=something envsubst < _template.guard.sh > something.guard.sh

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
declare -a _rest=( $(u.parse _option "$@") )
_undo=''; trap -- 'eval ${_undo}; unset _option _rest _undo; trap -- - RETURN' RETURN
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    elif [[ -x "${BASH_SOURCE/.guard./.install.}" ]] ; then
        "${BASH_SOURCE/.guard./.install.}" "$@"
    else        
        $(u.here)/guard.install.sh ${BASH_SOURCE%%.*} "$@"
    fi
fi

# template itself
# not working
_pkgx.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _pkgx_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _pkgx_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _pkgx_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _pkgx.parse

pkgx.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" https://docs.pkgx.sh/
)


pkgx.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x pkgx.env

pkgx.session() {
    source <(pkgx --shellcode) || return $(u.error "${FUNCNAME} failed")
}
f.x pkgx.session

loaded "${BASH_SOURCE}"
