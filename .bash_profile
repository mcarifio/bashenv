# .bash_profile

source "$(dirname $(realpath -Lm ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
[[ -z "${SSH_CONNECTION}" ]] && return 0
>&2 echo "bashenv.init ## next"



