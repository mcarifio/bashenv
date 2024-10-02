# .bash_profile

source "$(dirname $(realpath -Lm ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
# [[ -z "${SSH_CONNECTION}" ]] && return 0
echo "bashenv.init --trace ## next" >&2




