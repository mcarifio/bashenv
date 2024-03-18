direnv.session() {
    source <(direnv hook $(u.shell 2>/dev/null || echo bash)) || u.error
}
declare -fx direnv.session
direnv.session

