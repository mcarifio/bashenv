${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

poetry.session() {
    source <(poetry completions $(u.shell))
}
f.x poetry.session
poetry.session

sourced || true

