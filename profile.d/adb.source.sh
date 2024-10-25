${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

adb() ( command ${FUNCNAME} "$@"; )
f.x adb

adb.doc.urls() ( echo ; ) # urls here
f.x adb.doc.urls

adb.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x adb.doc

adb.env() {
    : '# called (once) by .bash_profile'
    sudo adb start-server
    adb devices &> /dev/null && return 0
    echo "${FUNCNAME} cannot list devices? Check each handset for messages." >&2
    return 1
}
f.x adb.env

adb.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x adb.session

adb.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x adb.installer

adb.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x adb.config.dir

adb.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x adb.config


sourced || true
