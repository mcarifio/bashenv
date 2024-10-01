# .bash_profile
${1:-false} || [[ -n "${SSH_CONNECTION}" ]] && return 0

source "$(dirname $(realpath -Lm ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin $(bashenv.root)/.local/bin
# declare -Ax=__bashenv_sourced( $(bashenv.init) )
>&2 echo "bashenv.init ## next"



