${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# rg() ( command ${FUNCNAME} "$@"; )
# f.x rg

rg.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x rg.docs

rg.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rg.env

rg.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}{,.${_shell}}
}
f.x rg.session

rg.installer() ( ls -1 $(bashenv.profiled)/binstall.d/ripgrep.*.binstall.sh; )
f.x rg.installer

sourced || true
