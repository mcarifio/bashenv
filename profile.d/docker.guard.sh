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
_docker.parse() (
    : '## example: parse callers arglist'
    set -uEeo pipefail
    shopt -s nullglob
    declare -A _docker_options=([file]="${PWD}/${FUNCNAME}" [comment]="${HOSTNAME}:and_some_stuff" [trace]=0)
    local -a _rest=( $(u.parse _docker_options --foo=bar --user=${USER} --trace 1 2 3) )
    printf '%s ' ${FUNCNAME}; declare -p _docker_options; printf '%s ' ${_rest[@]}
)

# TODO mike@carif.io: logic needs fixing
f.x _docker.parse

docker.clean.all() (
    : '## remove *all* local images'
    set -uEeo pipefail
    docker rmi --force $(docker images --quiet --all)
)
f.x docker.clean.all

docker.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open https://docs.docker.com/ ${_docs:-} "$@" # hard-code urls here if desired
)


docker.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x docker.env

docker.session() {
    { u.have docker-credential-desktop && source <(docker-credential-desktop completion $(u.shell 2>/dev/null || echo bash)); } || true
}
f.x docker.session

loaded "${BASH_SOURCE}"
