${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

snap() (
    sudo $(type -P ${FUNCNAME}) "$@"
)
f.x snap

snap.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x snap.docs

snap.env() {
    : '# called (once) by .bash_profile'
    systemctl is-active snapd &> /dev/null || echo "${FUNCNAME} snapd not active" >&2
)
f.x snap.env

snap.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x snap.session

snap.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*snapd*.*.binstall.sh; )
f.x snap.installer

sourced || true

