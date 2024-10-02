${1:-false} || type -P $(path.basename.part ${BASH_SOURCE} 0) &> /dev/null || return 0

snap() (
    sudo $(type -P ${FUNCNAME}) "$@"
)
f.x snap

snap.doc.urls() ( echo ; ) # urls here
f.x snap.doc.urls

snap.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x snap.doc

snap.env() {
    : '# called (once) by .bash_profile'
    systemctl is-active snapd &> /dev/null || echo "${FUNCNAME} snapd not active" >&2
}
f.x snap.env

snap.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}{,.${_shell}}
}
f.x snap.session

snap.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x snap.installer

sourced || true

