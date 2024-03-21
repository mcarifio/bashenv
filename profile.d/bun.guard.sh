bun.session() {
    source <(${FUNCNAME%.*} completions) || return $(u.error "${FUNCNAME} could not load bun completions")
}
f.x bun.session
bun.session

