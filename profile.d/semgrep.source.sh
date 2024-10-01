# usage: [guard | source] ${guard}.guard.sh [--install] [--verbose] [--trace]
# creation: guard=something envsubst < _template.guard.sh > something.guard.sh

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([verbose]=0 [trace]=0)
declare -a _rest=( $(u.parse _option "$@") )
_undo=''; trap -- 'eval ${_undo}; unset _option _rest _undo; trap -- - RETURN' RETURN
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi

# template itself
# not working
_semgrep.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _semgrep_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _semgrep_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _semgrep_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _semgrep.parse

semgrep.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)


semgrep.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x semgrep.env

semgrep.session() {
    # TODO mike@carifio: does login find ~/.semgrep/settings.yml?
    export SEMGREP_APP_TOKEN=3599e8cfe747d3778e02ac613a048836f0819d6731be7d1ac5ca65b1709fbcf2
    semgrep login || return $(u.error "${FUNCNAME} failed")
}
f.x semgrep.session

loaded "${BASH_SOURCE}"
