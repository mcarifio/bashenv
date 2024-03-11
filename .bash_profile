# .bash_profile

bashenv.profile() {
    local _bashenv_root="$(bashenv.root 2>/dev/null || dirname $(realpath -P ${BASH_SOURCE}))"
    local _bashenv_lib="$(bashenv.lib 2>/dev/null || echo $(dirname $(realpath -P ${BASH_SOURCE}))/${1-bashenv.lib.sh})"
    source "${_bashenv_lib}" || { >&2 echo "'${_bashenv_lib}' not found"; return 1; }
    path.add.all $(home)/opt/*/current/bin $(home)/.config/*/bin $(home)/bin $(home)/.local/bin $(bashenv.root)/bin
    u.map.tree source "$(bashenv.root)/.bash_profile.d"
    u.map.tree guard "$(bashenv.root)/.bash_profile.d"
}
declare -fx bashenv.profile
bashenv.profile

