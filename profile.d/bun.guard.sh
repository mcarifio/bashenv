# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

bun.session() {
    source <(${FUNCNAME%.*} completions) || return $(u.error "${FUNCNAME} could not load bun completions")
}
f.x bun.session
bun.session

loaded "${BASH_SOURCE}"
