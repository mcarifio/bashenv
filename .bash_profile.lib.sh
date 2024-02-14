home() ( getent passwd ${SUDO_USER:-${USER}} | cut -d: -f6; ); declare -fx home

path.login() (
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin
); declare -fx path.login


source.all() {
    for _a in $@; do
	source "${_a}" || >&2 echo "'${_a}' => $?" || true
    done
}; declare -fx source.all

source.find() {
    local -r _root="${1:?'expecting a folder'}"
    source.all $(find "${_root}" -regex '[^#]+\.sh$')
}; declare -fx source.find

source.bash_profile.d() {
    source.find $(home)/.bash_profile.d
}; declare -fx source.bash_profile.d

source.bashrc.d() {
    source.find $(home)/.bashrc.d
}; declare -fx source.bashrc.d

source.bash_completion.d() {
    source.find $(home)/.local/bash_completion.d
}; declare -fx source.bash_completion.d

running.bash() { realpath /proc/$$/exe | grep -Eq 'bash$' || return 0; }; declare -fx running.bash
has() ( &> /dev/null type ${1?:'expecting a command'} || >&2 echo "missing $1"; ); declare -fx has
has.all() ( for _a in "$@"; do has $_a; done; ); declare -fx has.all
