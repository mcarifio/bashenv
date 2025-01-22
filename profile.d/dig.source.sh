${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

dig() (
    command ${FUNCNAME} "$@"
)
f.x dig


dig.ip4() ( 
    : '${_dnsname} ## get the first ip4 address for ${_dnsname} using local machine search path (e.g. /etc/resolv.conf) '
    dig +short "${1:?"${FUNCNAME} expecting a dns name"}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1
)
f.x dig.ip4

dig.x() (
    dig +short -x "${1:?"${FUNCNAME} expecting an ip address"}" | tr '[:upper:]' '[:lower:]'
)
f.x dig.x



dig.doc.urls() (
    local -A _urls=(
        [start]=""
        [doc]=""
        [vcs]=""
        [blog]=""
        [irc]=""
    )
    echo ${_urls[${1:-@}]}
)
f.x dig.doc.urls

dig.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x dig.doc

dig.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x dig.env

dig.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x dig.session

dig.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x dig.installer

dig.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x dig.config.dir

dig.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x dig.config


sourced || true
