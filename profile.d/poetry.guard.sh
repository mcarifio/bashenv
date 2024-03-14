poetry.session() {
    source <(poetry completions $(u.shell 2>/dev/null || echo bash))
}
f.complete poetry.session
poetry.session
