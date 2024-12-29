path.add "${HOME}/.elan/bin"
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

elan.doc.urls() ( echo https://lean-lang.org/lean4/doc https://github.com/leanprover/lean4; ) # urls here
f.x elan.doc.urls

elan.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x elan.doc


elan.session() {
    : '# called by .bashrc'
    source <(elan completions $(u.shell))
}
f.x elan.session

sourced

