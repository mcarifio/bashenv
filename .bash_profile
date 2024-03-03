# .bash_profile

source $(realpath ${BASH_SOURCE}).lib.sh || true
u.map.tree source "$(bashenv.root)/.bash_profile.d"
u.map.tree guard "$(bashenv.root)/.bash_profile.d"
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/.local/bin
