# echo ${1:-false} $(path.basename.part ${BASH_SOURCE} 0) >&2
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0 # && echo sourcing ${BASH_SOURCE} >&2

unalias ls &> /dev/null || true

ls() ( command eza "$@"; )
f.x ls

eza.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    xdg-open ${_docs:-} https://the.exa.website/ "$@" # hard-code urls here if desired
)
f.x eza.docs

eza.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x eza.env

eza.session() {
    : '# called by .bashrc'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x eza.session

eza.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; ); f.x eza.installer

sourced || true
