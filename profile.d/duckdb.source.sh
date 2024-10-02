${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

duckdb() ( command ${FUNCNAME} "$@"; )
f.x duckdb

duckdb.doc.urls() ( echo ; ) # urls here
f.x duckdb.doc.urls

duckdb.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x duckdb.doc

duckdb.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x duckdb.env

duckdb.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}{,.${_shell}}
}
f.x duckdb.session
duckdb.session

duckdb.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x duckdb.installer

sourced || true



