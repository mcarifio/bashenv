${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

semgrep.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)

semgrep.authed() ( semgrep show identity 2>&1 | grep --silent --fixed-strings ${1:-${USER}}; )
f.x semgrep.authed

semgrep.env() {
    # TODO mike@carifio: does login find ~/.semgrep/settings.yml?
    semgrep.authed || SEMGREP_APP_TOKEN=3599e8cfe747d3778e02ac613a048836f0819d6731be7d1ac5ca65b1709fbcf2 semgrep login || return $(u.error "${FUNCNAME} failed")
}
f.x semgrep.env

semgrep.session() {    
    true || return $(u.error "${FUNCNAME} failed")
}
f.x semgrep.session

semgrep.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x semgrep.installer

sourced || true

