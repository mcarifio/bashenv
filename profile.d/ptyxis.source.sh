${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

ptyxis.doc() (
    set -uEeo pipefail
    xdg-open "https://gitlab.gnome.org/chergert/ptyxis"
)
f.x ptyxis.doc

ptyxis.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ptyxis.env

ptyxis.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x ptyxis.session

sourced || true

