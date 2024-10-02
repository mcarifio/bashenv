${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

rustup.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" "file://$(rustup show home)/toolchains/$(rustup show active-toolchain|cut -f1 -d' ')/share/doc/rust/html/index.html" # hard-code urls here if desired
)


rustup.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rustup.env

rustup.session() {
    source <(rustup completions $(u.shell)) || return $(u.error "${FUNCNAME} completions failed")
    source <(rustup completions $(u.shell) cargo) || return $(u.error "${FUNCNAME} cargo completions failed")
}
f.x rustup.session

rustup.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x rustup.installer

sourced || true
