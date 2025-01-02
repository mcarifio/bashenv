${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

evcxr() ( command ${FUNCNAME} "$@"; )
f.x evcxr

# evcxr isn't very memorable.
rsrepl() ( evcxr "$@"; )
f.x rsrepl


evcxr.doc.urls() ( echo https://github.com/evcxr/evcxr/blob/main/evcxr_repl/; ) # urls here
f.x evcxr.doc.urls

evcxr.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x evcxr.doc

evcxr.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x evcxr.env

evcxr.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x evcxr.session

evcxr.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x evcxr.installer

evcxr.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x evcxr.config.dir

evcxr.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x evcxr.config


sourced || true
