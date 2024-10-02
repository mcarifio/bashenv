${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

uv.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls
    set -x; xdg-open ${_docs:-} "$@" https://github.com/astral-sh/uv
)


uv.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x uv.env

# only works with dnf installs
uv.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x uv.session

uv.installer() (
    set -Eeuo pipefail; shopt -s nullglob
    ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh
)
f.x uv.installer

sourced || true
