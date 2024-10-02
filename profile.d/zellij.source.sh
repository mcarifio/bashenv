${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

zellij.doc.urls() ( echo ; ) # urls here
f.x zellij.doc.urls

zellij.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x zellij.doc

zellij.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x zellij.env

zellij.session() {
    : '# called by .bashrc'
    source <(zellij setup --generate-completion $(u.shell)) || return $(u.error "${FUNCNAME} failed")
}
f.x zellij.session

zellij.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x zellij.installer

sourced || true
