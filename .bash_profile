# .bash_profile

# TODO mike@carif.io: better way to handle this?
[[ -n "${SSH_CONNECTION}" ]] && return 0

source "$(dirname $(realpath -P ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin


declare -ax _bashenv_folders=()

# u.map.tree guard "$(bashenv.root)/profile.d"
# u.map.tree source "$(bashenv.root)/profile-${USER}.d"

for _tree in "$(bashenv.root)/profile.d" "$(bashenv.root)/profile-${USER}.d"; do
    for _action in source guard; do
        u.map.tree ${_action} "${_tree}"
    done
    _bashenv_folders+=($_tree)
done

bashenv.folders() { echo ${_bashenv_folders[@]}; }
f.x bashenv.folders
