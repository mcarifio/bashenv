${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) rlwrap || return 0

# go repl
yaegi() (
    set -Eeuo pipefail
    rlwrap command yaegi $@
)
f.x yaegi # rlwrap


yaegi.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" https://github.com/traefik/yaegi https://pkg.go.dev/github.com/traefik/yaegi # hard-code urls here if desired
)
f.x yaegi.docs


yaegi.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yaegi.env

yaegi.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yaegi.session


yaegi.installer() (
    set -Eeuo pipefail; # shopt -s nullglob
    # ls colorcodes output
    ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh
)
f.x yaegi.installer

sourced || true
