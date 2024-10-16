${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

torbrowser-launcher() ( command ${FUNCNAME} "$@"; )
f.x torbrowser-launcher

torbrowser-launcher.downloads() ( echo ${HOME}/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/Downloads/; )
f.x torbrowser-launcher.downloads


torbrowser-launcher.doc.urls() ( echo ; ) # urls here
f.x torbrowser-launcher.doc.urls

torbrowser-launcher.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x torbrowser-launcher.doc

torbrowser-launcher.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x torbrowser-launcher.env

torbrowser-launcher.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x torbrowser-launcher.session

torbrowser-launcher.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x torbrowser-launcher.installer

torbrowser-launcher.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x torbrowser-launcher.config.dir

torbrowser-launcher.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x torbrowser-launcher.config


sourced || true
