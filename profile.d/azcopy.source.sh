${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

azcopy.session() {
    function INFO:() { : ; } # fake out azcopy source command
    source <(azcopy completion $(u.shell)) || return $(u.error "${FUNCNAME} failed")
    unset INFO:
}
f.x azcopy.session

sourced




