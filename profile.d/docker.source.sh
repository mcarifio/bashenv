${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

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
    u.have docker-credential-desktop && source <(docker-credential-desktop completion $(u.shell))
    true
}
f.x docker.session

sourced
