azcopy.session() {
    function INFO:() { : ; } # fake out azcopy source command
    source <(azcopy completion bash) || u.error
    unset INFO:
}
declare -fx azcopy.session

