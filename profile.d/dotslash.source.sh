${1:-false} || u.have $(path.basename.part ${BASH_SOURCE} 0) || return 0

dotslash() (
    command ${FUNCNAME} "$@"
)
f.x dotslash

dotslash.doc.urls() (
    local -A _urls=(
        [start]=""
        [doc]=""
        [vcs]=""
        [blog]=""
        [irc]=""
    )
    echo ${_urls[${1:-@}]}
)
f.x dotslash.doc.urls

dotslash.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x dotslash.doc

dotslash.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x dotslash.env

dotslash.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x dotslash.session

dotslash.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x dotslash.installer

dotslash.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x dotslash.config.dir

dotslash.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x dotslash.config


sourced || true
