poetry.session() {
    source <(poetry completions $(u.shell 2>/dev/null || echo bash)) || u.error
}
f.x poetry.session
poetry.session

loaded "${BASH_SOURCE}"
