# usage: [guard | source] ${guard}.guard.sh [--install] [--verbose] [--trace]
# creation: guard=something envsubst < _template.guard.sh > something.guard.sh

# Front matter. Parse the source command line. Install by platform if --install,
# trace (and revert) if --trace.
_guard=$(path.basename ${BASH_SOURCE})

# not working
_yaegi.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _yaegi_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _yaegi_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _yaegi_options; printf '%s ' ${_rest[@]}
)
# TODO mike@carif.io: logic needs fixing
f.x _yaegi.parse

# go repl
yaegi() (
    set -Eeuo pipefail
    rlwrap command yaegi $@
)
f.x yaegi # rlwrap


yaegi.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" https://github.com/traefik/yaegi https://pkg.go.dev/github.com/traefik/yaegi # hard-code urls here if desired
)
f.x yaegi.docs


yaegi.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yaegi.env

yaegi.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yaegi.session

loaded "${BASH_SOURCE}"
