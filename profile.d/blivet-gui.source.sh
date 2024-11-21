${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

blivet-gui() ( command ${FUNCNAME} "$@"; )
f.x blivet-gui

blivet-gui.doc.urls() ( echo ; ) # urls here
f.x blivet-gui.doc.urls

blivet-gui.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x blivet-gui.doc

blivet-gui.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x blivet-gui.env

blivet-gui.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x blivet-gui.session

blivet-gui.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x blivet-gui.installer

blivet-gui.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x blivet-gui.config.dir

blivet-gui.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x blivet-gui.config


sourced || true
