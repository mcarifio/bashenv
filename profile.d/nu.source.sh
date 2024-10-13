${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

nu() ( command ${FUNCNAME} "$@"; )
f.x nu

nu.doc.urls() ( echo ; ) # urls here
f.x nu.doc.urls

nu.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x nu.doc

nu.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x nu.env

nu.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x nu.session

nu.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer nushell
)
f.x nu.installer

nu.config.dir() ( echo "${HOME}/.config/${FUNCNAME%.*}"; )
f.x nu.config.dir

nu.config() ( echo "$(${FUNCNAME}.dir)/${FUNCNAME##*.}"; ) ## tbs
nu.config

nu.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x nu.config.dir

nu.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x nu.config


sourced || true
