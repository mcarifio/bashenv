${1:-false} || u.haveP cargo-create-$(path.basename.part ${BASH_SOURCE} 0)-app || return 0

tauri.cmd() ( echo cargo-create-${FUNCNAME%%.*}-app; )
f.x tauri.cmd

tauri() ( command $(tauri.cmd) "$@"; )
f.x tauri

tauri.doc.urls() ( echo https://tauri.app/ https://github.com/tauri-apps/tauri https://github.com/tauri-apps/awesome-tauri; ) # urls here
f.x tauri.doc.urls

tauri.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x tauri.doc

tauri.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x tauri.env

tauri.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x tauri.session

tauri.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x tauri.installer

tauri.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${XDG_CONFIG_DIR:-${HOME}/.config}/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x tauri.config.dir

tauri.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x tauri.config


sourced || true
