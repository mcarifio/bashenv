# usage: [guard | source] _template.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

azcopy.session() {
    function INFO:() { : ; } # fake out azcopy source command
    source <(azcopy completion bash) || return $(u.error "${FUNCNAME} failed")
    unset INFO:
}
f.x azcopy.session

loaded "${BASH_SOURCE}"



