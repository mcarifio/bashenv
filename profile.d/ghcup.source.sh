${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

ghcup() ( command ${FUNCNAME} "$@"; )
f.x ghcup

ghcup.doc.urls() ( echo https://www.haskell.org/ghcup/ https://www.haskell.org/documentation/; ) # urls here
f.x ghcup.doc.urls

ghcup.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x ghcup.doc

ghcup.env() {
    : '# called (once) by .bash_profile'
    source.if ~/.local/share/ghcup/env
}
f.x ghcup.env

ghcup.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x ghcup.session

ghcup.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x ghcup.installer

ghcup.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x ghcup.config.dir

ghcup.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x ghcup.config


sourced || true
