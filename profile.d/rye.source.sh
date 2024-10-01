# usage: [guard | source] ${guard}.guard.sh [--install] [--verbose] [--trace]
# creation: guard=something envsubst < _template.guard.sh > something.guard.sh

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})

# not working
_rye.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _rye_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _rye_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _rye_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _rye.parse


rye.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rye.env

rye.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rye.session

loaded "${BASH_SOURCE}"
