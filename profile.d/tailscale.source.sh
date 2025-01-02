${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

tailscale() ( command ${FUNCNAME} "$@"; )
f.x tailscale

tailscale.doc.urls() (
    echo https://tailscale.com/kb/1017/install \
         https://github.com/tailscale/tailscale \
         https://login.tailscale.com/admin/machines ; ) # urls here
f.x tailscale.doc.urls

tailscale.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x tailscale.doc

tailscale.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x tailscale.env

tailscale.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x tailscale.session

tailscale.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    realpath -Lm $(binstall.installer ${FUNCNAME%.*})
)
f.x tailscale.installer

tailscale.config.dir() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="${HOME}/.config/${_guard}"
    [[ -d "${_dir}" ]] || return $(u.error "${FUNCNAME} '${_dir}' not found")
    echo ${_dir}
)
f.x tailscale.config.dir

tailscale.config() (
    set -Eeuo pipefail; shopt -s nullglob
    local _guard="${FUNCNAME%%.*}"
    local _dir="$(${FUNCNAME}.dir)"
    local _config="${_dir}/${_guard}"
    [[ -r "${_config}" ]] || return $(u.error "${FUNCNAME} '${_config}' not found")
    echo "${_config}"
)
f.x tailscale.config


sourced || true
