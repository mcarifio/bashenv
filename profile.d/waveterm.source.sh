${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

waveterm() ( command ${FUNCNAME} "$@"; )
f.x waveterm

waveterm.doc.urls() (
    local -A _urls=( [start]="https://www.waveterm.dev/" [doc]="https://docs.waveterm.dev/" [vcs]="https://github.com/wavetermdev/waveterm" )
    echo ${_urls[@]}
)
f.x waveterm.doc.urls

waveterm.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x waveterm.doc

waveterm.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x waveterm.env

waveterm.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x waveterm.session

waveterm.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x waveterm.installer

waveterm.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x waveterm.config.dir

waveterm.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x waveterm.config


sourced || true
