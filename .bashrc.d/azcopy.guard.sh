function INFO:() { : ; } # fake out azcopy source command
source <(azcopy completion bash)
unset INFO:
