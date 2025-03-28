${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

eget() ( command ${FUNCNAME} "$@"; )
f.x eget

eget.doc.urls() ( echo https://github.com/zyedidia/eget; ) # urls here
f.x eget.doc.urls

eget.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x eget.doc

eget.env() {
    : '# called (once) by .bash_profile'
    local _name=${FUNCNAME%%.*}
    export EGET_CONFIG=~/.config/${_name}/${_name}.toml  # || return $(u.error "${FUNCNAME} failed")
}
f.x eget.env

eget.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x eget.session

eget.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x eget.installer

eget.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x eget.config.dir

eget.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x eget.config


sourced || true
