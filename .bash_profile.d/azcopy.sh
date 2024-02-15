running.bash && u.have $(basename ${BASH_SOURCE} .sh) || return 0

function INFO:() { : ; } # fake out azcopy source command
source <(azcopy completion bash)
unset INFO:

