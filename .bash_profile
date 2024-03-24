# .bash_profile

bashenv.profile() {
    local _bashenv_root="$(bashenv.root 2>/dev/null || dirname $(realpath -P ${BASH_SOURCE}))"
    local _bashenv_lib="$(bashenv.lib 2>/dev/null || echo $(dirname $(realpath -P ${BASH_SOURCE}))/${1:-bashenv.lib.sh})"
    source "${_bashenv_lib}" || { >&2 echo "'${_bashenv_lib}' not found"; return 1; }
    path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin
    u.map.tree source "$(bashenv.root)/profile.d"
    u.map.tree guard "$(bashenv.root)/profile.d"
    u.map.tree source "$(bashenv.root)/profile-${USER}.d"
    u.map.tree guard "$(bashenv.root)/profile-${USER}.d"

}
f.x bashenv.profile
bashenv.profile

