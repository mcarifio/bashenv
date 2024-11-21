${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

play() ( command ${FUNCNAME} "$@"; )
f.x play

play.beep() ( play -n synth 0.5 sine 880; )
f.x play.beep

play.doc.urls() ( echo ; ) # urls here
f.x play.doc.urls

play.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x play.doc

play.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x play.env

play.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x play.session

play.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x play.installer

play.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x play.config.dir

play.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x play.config


sourced || true
