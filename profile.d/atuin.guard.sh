# usage: [guard | source] atuin.guard.sh [--install] [--verbose] [--trace]

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})

# not working
atuin.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A atuin_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse atuin_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p atuin_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x atuin.parse


atuin.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.env

atuin.session() {
    [[ -n "$SSH_CLIENT" ]] && return 0
    [[ -f /usr/share/bash-prexec ]] && source /usr/share/bash-prexec
    source <(atuin init bash) || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.session

loaded "${BASH_SOURCE}"
