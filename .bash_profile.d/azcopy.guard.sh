azcopy.session() {
    function INFO:() { : ; } # fake out azcopy source command
    source <(azcopy completion bash)
    unset INFO:
}
declare -fx azcopy.session

