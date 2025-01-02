${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

warp-terminal() ( command ${FUNCNAME} "$@"; )
f.x warp-terminal

warp-terminal.doc.urls() ( echo https://docs.warp.dev/; ) # urls here
f.x warp-terminal.doc.urls

warp-terminal.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x warp-terminal.doc

warp-terminal.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x warp-terminal.env

warp-terminal.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    # nothing installed, warp-terminal completions doesn't exists either
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x warp-terminal.session

warp-terminal.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x warp-terminal.installer

warp-terminal.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x warp-terminal.config.dir

warp-terminal.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x warp-terminal.config


sourced || true
