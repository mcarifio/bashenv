poetry.session() {
    source <(poetry completions $(u.shell 2>/dev/null || echo bash)) || u.error
}
f.complete poetry.session
poetry.session
