${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

rdap() ( command ${FUNCNAME} "$@"; )
f.x rdap

rdap.exists() (
    : '${_tld} # return 0 iff top level domain ${_tld} exists'
    set -Eeuo pipefail
    local _tld="${1:?'expecting a top level domain e.g. google.com'}"
    &>/dev/null rdap "${_tld}"
)
f.x rdap.exists

rdap.browse() (
    : '${_tld} # browse http://${_tld} iff ${_tld} is registered.'
    set -Eeuo pipefail
    local _tld="${1:?'expecting a top level domain e.g. google.com'}"
    rdap.exists ${_tld} && xdg-open http://${_tld} || return $(u.error "${_tld} not registered")
)
f.x rdap.browse

rdap.summary() (
    : '${_tld} # summarize ${_tld} iff ${_tld} is registered.'
    set -Eeuo pipefail
    local _tld="${1:?'expecting a top level domain e.g. google.com'}"
    # rdap --json "${_tld}" | jq .
    rdap --json "${_tld}" | jq .ldhName
)
f.x rdap.summary

rdap.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x rdap.docs

rdap.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rdap.env

rdap.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    # local -r _completions=/usr/share/bash-completion/completions
    # source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x rdap.session

rdap.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x rdap.installer

sourced || true
