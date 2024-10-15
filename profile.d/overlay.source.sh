${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

overlay() ( command ${FUNCNAME} "$@"; )
f.x overlay

overlay.doc.urls() ( echo ; ) # urls here
f.x overlay.doc.urls

overlay.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x overlay.doc

overlay.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x overlay.env

overlay.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x overlay.session

overlay.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer overlayfs-tools
)
f.x overlay.installer

overlay.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x overlay.config.dir

overlay.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x overlay.config


sourced || true
