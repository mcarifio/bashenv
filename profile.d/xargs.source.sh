${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

xargs.1() ( command ${FUNCNAME%.*} --max-args=1 "$@"; )
f.x xargs.1


xargs.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x xargs.docs

xargs.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x xargs.env

xargs.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}.${_shell}
}
f.x xargs.session

xargs.installer() (
    set -Eeuo pipefail; # shopt -s nullglob
    # ls colorcodes output
    ls -1 $(bashenv.profiled)/binstall.d/*findutils*.*.binstall.sh
)
f.x xargs.installer

sourced || true
