${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

whois() ( command ${FUNCNAME} "$@"; )
f.x whois

whois.open() (
    local _cmd=${FUNCNAME%%.*}
    local _tld="${1:?"${FUNCNAME} expecting a tld"}"
    ${_cmd} "${_tld}" &> /dev/null || return $(u.error "No registration for tld '${_tld}'")
    local _url="http://www.${_tld}/"
    >&2 echo "Opening '${_url}' in default browser"
    xdg-open "${_url}"
)
f.x whois.open


whois.doc.urls() ( echo ; ) # urls here
f.x whois.doc.urls

whois.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x whois.doc

whois.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x whois.env

whois.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x whois.session

whois.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x whois.installer

whois.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x whois.config.dir

whois.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x whois.config


sourced || true
