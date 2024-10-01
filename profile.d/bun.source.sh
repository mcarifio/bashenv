${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

bun.session() {
    source <(${FUNCNAME%.*} completions) || return $(u.error "${FUNCNAME} could not load bun completions")
}
f.x bun.session
bun.session

sourced

