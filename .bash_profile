# .bash_profile
source "$(dirname $(realpath -P ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin
u.map.tree source "$(bashenv.root)/profile.d"
u.map.tree guard "$(bashenv.root)/profile.d"
u.map.tree source "$(bashenv.root)/profile-${USER}.d"
u.map.tree guard unset _bashenv_{root,lib}


