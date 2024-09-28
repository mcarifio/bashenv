# .bash_profile

# TODO mike@carif.io: better way to handle this?
[[ -n "${SSH_CONNECTION}" ]] && return 0

source "$(dirname $(realpath -Lm ${BASH_SOURCE}))/bashenv.lib.sh" || { >&2 echo "'bashenv.lib.sh' not found"; return 1; }
path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin

# u.map.tree guard "$(bashenv.root)/profile.d"
# u.map.tree source "$(bashenv.root)/profile-${USER}.d"

# for _tree in "$(bashenv.root)/profile.d" "$(bashenv.root)/profile-${USER}.d"; do
#     for _action in lib source guard; do
#         u.map.tree ${_action} "${_tree}"
#     done
#     _bashenv_folders+=($_tree)
# done

bashenv.profiled() ( find $(bashenv.root) -mindepth 1 -maxdepth 1 -name profile*.d -type d; )
f.x bashenv.profiled

bashenv.source.kinds() {
    local -i _depth=${1:?'expecting a depth'}; shift
    local -a _kinds=( ${1//:/ } ); shift
    # declare -p _kinds
    for _kind in @{_kinds[*]}; do u.map.trees ${_depth} ${_kind} source $@; done
}

f.x bashenv.source.kinds

# bashenv.source.kinds 1 lib $(bashenv.root)
# bashenv.source.kinds 2 source:guard $(bashenv.profiled)

