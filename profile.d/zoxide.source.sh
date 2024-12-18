${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# zoxide() ( command ${FUNCNAME} "$@"; )
# f.x zoxide

zoxide.doc.urls() ( echo ; ) # urls here
f.x zoxide.doc.urls

zoxide.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u} https://github.com/ajeetdsouza/zoxide; done
)
f.x zoxide.doc

zoxide.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x zoxide.env

# defines the `z` command
zoxide.session() {
    : '# called by .bashrc'
    source <(${FUNCNAME%.*} init $(u.shell))
}
f.x zoxide.session

zoxide.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x zoxide.installer

sourced || true
