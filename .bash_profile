# .bash_profile
source ~/bashenv/bashenv.lib.sh && >&2 echo "bashenv added"
u.map.tree source "$(bashenv.root)/.bash_profile.d"
u.map.tree guard "$(bashenv.root)/.bash_profile.d"
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin
