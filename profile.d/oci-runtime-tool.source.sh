${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

oci-runtime-tool() ( command ${FUNCNAME} "$@"; )
f.x oci-runtime-tool

oci-runtime-tool.doc.urls() ( echo ; ) # urls here
f.x oci-runtime-tool.doc.urls

oci-runtime-tool.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x oci-runtime-tool.doc

oci-runtime-tool.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x oci-runtime-tool.env

oci-runtime-tool.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x oci-runtime-tool.session

oci-runtime-tool.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x oci-runtime-tool.installer

oci-runtime-tool.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x oci-runtime-tool.config.dir

oci-runtime-tool.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x oci-runtime-tool.config


sourced || true
