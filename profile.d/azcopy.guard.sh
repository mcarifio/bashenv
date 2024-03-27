azcopy.session() {
    function INFO:() { : ; } # fake out azcopy source command
    source <(azcopy completion bash) || return $(u.error "${FUNCNAME} failed")
    unset INFO:
}
f.x azcopy.session

azcopy.loaded() ( return 0; )
f.x azcopy.loaded



